From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] PPTP: PPP over IPv4 (Point-to-Point Tunneling
 Protocol)
Date: Wed, 18 Aug 2010 14:23:15 -0700 (PDT)
Message-ID: <20100818.142315.183039464.davem@davemloft.net>
References: <1282119905.2194.38.camel@edumazet-laptop>
	<E1Olg2s-0007BB-00.xeb-mail-ru@f30.mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54967
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753155Ab0HRVW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 17:22:56 -0400
In-Reply-To: <E1Olg2s-0007BB-00.xeb-mail-ru@f30.mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kozlov <xeb@mail.ru>
Date: Wed, 18 Aug 2010 14:38:58 +0400

> Hi Eric!
> Thanks for comments. All your comments was accepted except:
> 
>> > +static struct ppp_channel_ops pptp_chan_ops = {
>> 
>> static const ?
> 
> not, because po->chan.ops = &pptp_chan_ops which is not const

Yes it is:

davem@sunset:~/src/GIT/linux-2.6$ git grep ppp_channel_ops -- include/linux/
include/linux/ppp_channel.h:struct ppp_channel_ops {
include/linux/ppp_channel.h:	const struct ppp_channel_ops *ops; /* operations for this channel */
davem@sunset:~/src/GIT/linux-2.6$ 
