From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Revert "xen-netback: improve ring effeciency
 for guest RX"
Date: Tue, 08 Oct 2013 15:11:23 -0400 (EDT)
Message-ID: <20131008.151123.1574778991747124379.davem@davemloft.net>
References: <1381226061-6521-1-git-send-email-wei.liu2@citrix.com>
	<1381227707.3804.65.camel@hastur.hellion.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, netdev@vger.kernel.org,
	xen-devel@lists.xen.org, annie.li@oracle.com, msw@amazon.com,
	xixiong@amazon.com, david.vrabel@citrix.com,
	paul.durrant@citrix.com
To: ian.campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53669 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752665Ab3JHTL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 15:11:27 -0400
In-Reply-To: <1381227707.3804.65.camel@hastur.hellion.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <ian.campbell@citrix.com>
Date: Tue, 8 Oct 2013 11:21:47 +0100

> On Tue, 2013-10-08 at 10:54 +0100, Wei Liu wrote:
>> This reverts commit 4f0581d25827d5e864bcf07b05d73d0d12a20a5c.
>> 
>> The named changeset is causing problem. Let's aim to make this part less
>> fragile before trying to improve things.
>> 
>> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> Acked-by: Ian Campbell <ian.campbell@citrix.com>
> 
> Although I thought davem would just run git revert so I don't know if it
> is needed.

This works too, because it gives you guys an opportunity to add
some explanation to the commit message.

Applied, thanks.
