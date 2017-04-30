From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next v2 10/11] ixgbevf: Fix errors in retrieving RETA and
 RSS from PF
Date: Sun, 30 Apr 2017 11:49:09 +0300
Message-ID: <b5230e20-145f-5446-eeb6-67d0e9939dd0@cogentembedded.com>
References: <20170430030810.56415-1-jeffrey.t.kirsher@intel.com>
 <20170430030810.56415-11-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:34176 "EHLO
        mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S969789AbdD3ItL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 04:49:11 -0400
Received: by mail-lf0-f49.google.com with SMTP id t144so50813499lff.1
        for <netdev@vger.kernel.org>; Sun, 30 Apr 2017 01:49:10 -0700 (PDT)
In-Reply-To: <20170430030810.56415-11-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 4/30/2017 6:08 AM, Jeff Kirsher wrote:

> From: Tony Nguyen <anthony.l.nguyen@intel.com>
>
> Mailbox support for getting RETA and RSS is available for only 82599 and
> x540; a previous patch reversed the logic and these adapters were
> returning not supported.
>
> Also, the NACK check in ixgbevf_get_rss_key_locked() was checking for the
> command IXGBE_VF_GET_RETA instead of IXGBE_VF_GET_RSS_KEY.

    "Also" is usually an indicator that you need one more patch. Don't do 2 
things in one patch, please.

> This patch corrects both issues by correcting the logic and checking for
> the right command.
>
> Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
[...]

MBR, Sergei
