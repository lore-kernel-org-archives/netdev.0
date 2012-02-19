From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: cap copy length at size of skb to prevent
 dropped frames on tx
Date: Sun, 19 Feb 2012 18:58:52 -0500 (EST)
Message-ID: <20120219.185852.396438198148869233.davem@davemloft.net>
References: <1329392936-14548-1-git-send-email-nhorman@tuxdriver.com>
	<19987954.351014.1329422822704.JavaMail.root@zimbra-prod-mbox-5.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, mmatveev@redhat.com, pv-drivers@vmware.com,
	netdev@vger.kernel.org
To: sbhatewara@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40637 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589Ab2BSX77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2012 18:59:59 -0500
In-Reply-To: <19987954.351014.1329422822704.JavaMail.root@zimbra-prod-mbox-5.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shreyas Bhatewara <sbhatewara@vmware.com>
Date: Thu, 16 Feb 2012 12:07:02 -0800 (PST)

> 
>> Also, since I'm unable to do this, it wuold be great if vmware could
>> follow up
>> this patch with some additional code commentary as to why 54 bytes is
>> an optimal
>> pull length for a virtual NIC driver.  The comment that introduced
>> this was
>> vague on that.  Thanks!
> 
> 
> Neil, thanks for the patch. We fixed this bug in local repositories
> recently and I was about to post a patch to LKML. As for the explanation,
> the vNIC is optimized to work with most frequently occurring headers(TCP)
> and hence needs particular number of bytes in first sg. Even in case of
> UDP this pull is cheaper (CPU utilization wise) to do in guest than in
> device emulation.
> 
> Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>

Applied.
