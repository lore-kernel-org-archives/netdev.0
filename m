From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2 1/1] vxlan: Add support for modifying vxlan
 device attributes
Date: Thu, 11 May 2017 11:12:22 -0700
Message-ID: <20170511111222.5edc4b0c@xeon-e3>
References: <1494095863-21916-1-git-send-email-girish.moodalbail@oracle.com>
        <1494095863-21916-2-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Girish Moodalbail <girish.moodalbail@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:36585 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932347AbdEKSMa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 14:12:30 -0400
Received: by mail-pf0-f180.google.com with SMTP id m17so17584741pfg.3
        for <netdev@vger.kernel.org>; Thu, 11 May 2017 11:12:30 -0700 (PDT)
In-Reply-To: <1494095863-21916-2-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  6 May 2017 11:37:43 -0700
Girish Moodalbail <girish.moodalbail@oracle.com> wrote:

> Ability to change vxlan device attributes was added to kernel through
> commit 8bcdc4f3a20b ("vxlan: add changelink support"), however one
> cannot do the same through ip(8) command.  Changing the allowed vxlan
> device attributes using 'ip link set dev <vxlan_name> type vxlan
> <allowed_attributes>' currently fails with 'operation not supported'
> error.  This failure is due to the incorrect rtnetlink message
> construction for the 'ip link set' operation.
> 
> The vxlan_parse_opt() callback function is called for parsing options
> for both 'ip link add' and 'ip link set'. For the 'add' case, we pass
> down default values for those attributes that were not provided as CLI
> options. However, for the 'set' case we should be only passing down the
> explicitly provided attributes and not any other (default) attributes.
> 
> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>

I like this much better.
Applied, Thanks.
