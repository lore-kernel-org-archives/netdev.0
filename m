From: David Miller <davem@redhat.com>
Subject: Re: [net] i40e: Change some init flow for the client
Date: Thu, 25 Aug 2016 17:00:42 -0700 (PDT)
Message-ID: <20160825.170042.2130538902727512633.davem@redhat.com>
References: <1472086313-121437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anjali.singhai@intel.com, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51964 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755731AbcHZAAt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 20:00:49 -0400
In-Reply-To: <1472086313-121437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 24 Aug 2016 17:51:53 -0700

> From: Anjali Singhai Jain <anjali.singhai@intel.com>
> 
> This change makes a common flow for Client instance open during init
> and reset path. The Client subtask can handle both the cases instead of
> making a separate notify_client_of_open call.
> Also it may fix a bug during reset where the service task was leaking
> some memory and causing issues.
> 
> Change-Id: I7232a32fd52b82e863abb54266fa83122f80a0cd
> Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks Jeff.
