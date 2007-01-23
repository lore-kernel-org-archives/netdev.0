From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: XFRM does not rate limit messages from the kernel to userspace
Date: Tue, 23 Jan 2007 10:42:43 +0100
Message-ID: <BAY103-DAV624D3E972A0B3ED4FE711B2AD0@phx.gbl>
References: <E1H9Hyc-0007MT-00@gondolin.me.apana.org.au>
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s4.bay0.hotmail.com ([65.54.246.76]:15747 "EHLO
	bay0-omc1-s4.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932927AbXAWJm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 04:42:57 -0500
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

> Marco Berizzi <pupilla@hotmail.com> wrote:
> > I'm experimenting the problem described in this
> > bug report http://bugs.xelerance.com/view.php?id=726
>
> It's actually a bug in openswan.  I even sent them a patch for
> it back in June 2005:
>
> http://bugs.xelerance.com/view.php?id=344
>
> Unfortunately it probably doesn't apply anymore.

AFAIK it was applied to osw 2.4.2
Also changelog confirm this:

v2.4.2
* Fixes for compiling on 2.6.14 by David McCullough
* Minor fixes to accomodate FC4 2.6.11 kernels.
* Fix for compilation of KLIPS on 2.4.x kernels.
* Fix for NAT-T on 2.4.31
* Fix for 'short' packets with KLIPS on 2.4.x
* Merged in Jacco's l2tp configuration examples
* Various bugfixes as reported on http://bugs.openswan.org/
  #286 Incorrect links in intro.html
  #344 netkey-acquire patch
  #376 install_ipsec_sa and install_inbound_ipsec_sa
  #486 ASSERTION FAILED at crypto.c:258: key_size==(DES_CBC_BLOCK_SIZE *
3)
  (see http://www.openswan.org/niscc2/)


