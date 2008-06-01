From: David Miller <davem@davemloft.net>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Sun, 01 Jun 2008 09:01:27 -0700 (PDT)
Message-ID: <20080601.090127.193706900.davem@davemloft.net>
References: <4835A007.7020601@krogh.cc>
	<20080522.104145.193700531.davem@davemloft.net>
	<20080601072528.GA786@pazke.donpac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesper@krogh.cc, Matheos.Worku@Sun.COM, yhlu.kernel@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: pazke@pazke.donpac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48108
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753205AbYFAQBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 12:01:31 -0400
In-Reply-To: <20080601072528.GA786@pazke.donpac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrey Panin <pazke@pazke.donpac.ru>
Date: Sun, 1 Jun 2008 11:25:28 +0400

> On 143, 05 22, 2008 at 10:41:45 -0700, David Miller wrote:
> > For now, yes.  The transmit path itself in the generic network
> > device layer is where the serialization comes from.
> 
> BTW does this problem affects bonded interfaces ?

The toplevel bond device uses lockless transmit because
it does not queue, so the arity of the locking is equal
to the arity of the number of slave devices sitting
under the toplevel bond device.
