From: David Miller <davem@davemloft.net>
Subject: Re: ping6 to own link-local address
Date: Wed, 28 Mar 2007 01:45:33 -0700 (PDT)
Message-ID: <20070328.014533.112621902.davem@davemloft.net>
References: <1174429000.3255.3.camel@w-sridhar2.beaverton.ibm.com>
	<20070321.002609.58216683.yoshfuji@linux-ipv6.org>
	<20070328.165748.48153731.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, netdev@vger.kernel.org, CHINEN@jp.ibm.com
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43367
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753235AbXC1Ipe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 04:45:34 -0400
In-Reply-To: <20070328.165748.48153731.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Wed, 28 Mar 2007 16:57:48 +0900 (JST)

> In article <20070321.002609.58216683.yoshfuji@linux-ipv6.org> (at Wed, 21 Mar 2007 00:26:09 +0100 (CET)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:
> 
> > In article <1174429000.3255.3.camel@w-sridhar2.beaverton.ibm.com> (at Tue, 20 Mar 2007 15:16:40 -0700), Sridhar Samudrala <sri@us.ibm.com> says:
> > 
> > > The following patch seems to be the cause for this regression.
> > > 
> > > [IPV6] ROUTE: Do not route packets to link-local address on other device.
> > > 
> > > http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=a0d78ebf3a0e33a1aeacf2fc518ad9273d6a1c2f
> > 
> > Right.  Hmm...
> 
> Well, 2.6.21 is coming.  I think it is better to revert it for now.
> Current situation is more critical than the original.
> 
> Dave?

I will look into this and make some kind of decision on how
to proceed tomorrow.
