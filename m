From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: ping6 to own link-local address
Date: Wed, 21 Mar 2007 00:26:09 +0100 (CET)
Message-ID: <20070321.002609.58216683.yoshfuji@linux-ipv6.org>
References: <20070320.101911.50437044.yoshfuji@linux-ipv6.org>
	<1174429000.3255.3.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, CHINEN@jp.ibm.com, yoshfuji@linux-ipv6.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:35074 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933890AbXCTXZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:25:31 -0400
In-Reply-To: <1174429000.3255.3.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <1174429000.3255.3.camel@w-sridhar2.beaverton.ibm.com> (at Tue, 20 Mar 2007 15:16:40 -0700), Sridhar Samudrala <sri@us.ibm.com> says:

> On Tue, 2007-03-20 at 10:19 +0100, YOSHIFUJI Hideaki / 吉藤英明 wrote:
> > Hello.
> > 
> > Recent 2.6.21-git kernels do not respond to ping6 queries
> > to our own (local) link-local address.  Now bisecting...
> 
> The following patch seems to be the cause for this regression.
> 
> [IPV6] ROUTE: Do not route packets to link-local address on other device.
> 
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=a0d78ebf3a0e33a1aeacf2fc518ad9273d6a1c2f

Right.  Hmm...

--yoshfuji
