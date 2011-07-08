From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: Omit check for multicast bit in
 netdev_for_each_mc_addr
Date: Fri, 08 Jul 2011 09:03:39 -0700 (PDT)
Message-ID: <20110708.090339.1003527654771987594.davem@davemloft.net>
References: <1310112386-13716-1-git-send-email-tklauser@distanz.ch>
	<1310114109.2755.18.camel@Joe-Laptop>
	<20110708084218.GK8334@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org, perex@perex.cz
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33278 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754057Ab1GHQDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 12:03:49 -0400
In-Reply-To: <20110708084218.GK8334@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Fri, 8 Jul 2011 10:42:18 +0200

> On 2011-07-08 at 10:35:09 +0200, Joe Perches <joe@perches.com> wrote:
>> On Fri, 2011-07-08 at 10:06 +0200, Tobias Klauser wrote:
>> > There is no need to check for the address being a multicast address in
>> > the netdev_for_each_mc_addr loop, so remove it.
>> > 
>> > There is no need to check for the address being a multicast address in
>> > the netdev_for_each_mc_addr loop, so remove it.
>> 
>> Thanks Tobias.
>> 
>> The commit message is a bit redundant, but this looks
>> good to me.
> 
> Oops, sorry. The first part should've gone away.
> 
> David, I can resend it with an adjusted commit message if you want, so
> you don't need to edit it.

I fixed it up when I applied this patch, thanks.
