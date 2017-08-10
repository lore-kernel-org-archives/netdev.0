From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] geneve: maximum value of VNI cannot be used
Date: Wed, 09 Aug 2017 22:41:30 -0700 (PDT)
Message-ID: <20170809.224130.1529052203716251519.davem@davemloft.net>
References: <1502238384-14440-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@ovn.org, netdev@vger.kernel.org
To: girish.moodalbail@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51828 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752253AbdHJFla (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 01:41:30 -0400
In-Reply-To: <1502238384-14440-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Girish Moodalbail <girish.moodalbail@oracle.com>
Date: Tue,  8 Aug 2017 17:26:24 -0700

> Geneve's Virtual Network Identifier (VNI) is 24 bit long, so the range
> of values for it would be from 0 to 16777215 (2^24 -1).  However, one
> cannot create a geneve device with VNI set to 16777215. This patch fixes
> this issue.
> 
> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>

I always worry that someone, somewhere, might be using this in some
way and this will break things.

But I'll apply this for now.
