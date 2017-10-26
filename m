From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] macvlan: remove unused fields in struct
 macvlan_dev
Date: Thu, 26 Oct 2017 10:12:04 +0900 (KST)
Message-ID: <20171026.101204.649975386378776877.davem@davemloft.net>
References: <1508959603-29062-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sainath.grandhi@intel.com
To: girish.moodalbail@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55990 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932240AbdJZBMH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 21:12:07 -0400
In-Reply-To: <1508959603-29062-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Girish Moodalbail <girish.moodalbail@oracle.com>
Date: Wed, 25 Oct 2017 12:26:43 -0700

> commit 635b8c8ecdd2 ("tap: Renaming tap related APIs, data structures,
> macros") captured all the tap related fields into a new struct tap_dev.
> However, it failed to remove those fields from struct macvlan_dev.
> Those fields are currently unused and must be removed. While there
> I moved the comment for MAX_TAP_QUEUES to the right place.
> 
> Fixes: 635b8c8ecdd27142 (tap: Renaming tap related APIs, data structures, macros)
> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>

Good catch, applied.

Thanks!
