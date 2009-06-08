From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] net: Fix skb_copy_datagram_from_iovec()
 to pass the right offset
Date: Mon, 08 Jun 2009 00:28:51 -0700 (PDT)
Message-ID: <20090608.002851.249913253.davem@davemloft.net>
References: <1244230540.1526.76.camel@w-sridhar.beaverton.ibm.com>
	<20090606212533.GD28614@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38341
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752372AbZFHH2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 03:28:49 -0400
In-Reply-To: <20090606212533.GD28614@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 7 Jun 2009 00:25:33 +0300

> On Fri, Jun 05, 2009 at 12:35:40PM -0700, Sridhar Samudrala wrote:
>> I am working on enabling UFO between KVM guests using virtio-net and i have 
>> some patches that i got working with 2.6.30-rc8. When i wanted to try them
>> with net-next-2.6, i noticed that virtio-net is not working with that tree.
>> 
>> After some debugging, it turned out to be several bugs in the recent patches
>> to fix aio with tun driver, specifically the following 2 commits.
>> 
>> http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=0a1ec07a67bd8b0033dace237249654d015efa21
>> http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=6f26c9a7555e5bcca3560919db9b852015077dae
>> 
>> 
>> Fix the call to memcpy_from_iovecend() in skb_copy_datagram_from_iovec
>> to pass the right iovec offset.
>> 
>> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> 
> Yes, looks like the bugs were around GSO handling, I was probably
> testing without GSO at the time. I'll go try with GSO now. Thanks for
> fixing these!
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>

Applied.
