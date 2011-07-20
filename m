From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch] skbuff: use kfree_skb() instead of kfree()
Date: Wed, 20 Jul 2011 11:01:09 +0300
Message-ID: <20110720080109.GH6445@shale.localdomain>
References: <20110720072343.GF6445@shale.localdomain>
 <20110720072549.GG6445@shale.localdomain>
 <1311147723.3113.116.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shirley Ma <xma@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58691 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080Ab1GTIDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 04:03:05 -0400
Content-Disposition: inline
In-Reply-To: <1311147723.3113.116.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2011 at 09:42:03AM +0200, Eric Dumazet wrote:
> Le mercredi 20 juillet 2011 =E0 10:25 +0300, Dan Carpenter a =E9crit =
:
> > Crap.  Sorry, I shouldn't have sent that.  We shouldn't return the
> > freed "n" here.  I'll send a v2 shortly.
>=20
> Also, dont forget to say its a patch for net-next-2.6

If you're using linux-next, is there a way to tell which tree a
patch came from?  Obviously in this case it's core networking, but
in other cases how does that work?

regards,
dan carpenter

