From: David Miller <davem@davemloft.net>
Subject: Re: RFC: Established connections hash function
Date: Wed, 28 Mar 2007 12:04:29 -0700 (PDT)
Message-ID: <20070328.120429.98555893.davem@davemloft.net>
References: <200703281129.43783.ak@suse.de>
	<20070328104505.GA18748@2ka.mipt.ru>
	<p73y7lh316u.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, nikb@webmaster.com, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36991
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965685AbXC1TEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 15:04:30 -0400
In-Reply-To: <p73y7lh316u.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: 28 Mar 2007 16:14:17 +0200

> Evgeniy Polyakov <johnpol@2ka.mipt.ru> writes:
> > 
> > Jenkins hash is far from being simple to crack, although with some
> > knowledge it can be done faster.
> 
> TCP tends to be initialized early before there is anything
> good in the entropy pool.

Andi, you're being an idiot.

You are spewing endless and uninformed bullshit about this secure hash
topic, and it must stop now!

You obviously didn't even read my patch, because if you did you would
have seen that I don't initialize the random seed until MUCH MUCH
later _EXACTLY_ to deal with this issue.

In my patch the random seed is initialized when the first TCP or DCCP
socket is created, at which point we'll have sufficient entropy.

So please stop talking such nonsense about this topic.
