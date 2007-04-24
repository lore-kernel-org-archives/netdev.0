From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] Fix build errors on 32bit platforms with new ktime
Date: Tue, 24 Apr 2007 20:48:22 +0200
Message-ID: <462E50F6.50700@cosmosbay.com>
References: <20070425.001743.19811068.yoshfuji@linux-ipv6.org>	<20070424155324.GL3468@stusta.de>	<20070425.005845.113682267.yoshfuji@linux-ipv6.org>	<20070425.011028.113320997.yoshfuji@linux-ipv6.org>	<20070424183827.adb60ae0.dada1@cosmosbay.com> <20070424100420.2860db68@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: YOSHIFUJI Hideaki / ____________ <yoshfuji@linux-ipv6.org>,
	bunk@stusta.de, davem@davemloft.net, netdev@vger.kernel.org,
	tglx@linutronix.de
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:43832 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423015AbXDXSvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 14:51:54 -0400
In-Reply-To: <20070424100420.2860db68@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger a =E9crit :
> =20
> +#define ktime_to_us(kt)			((kt).tv64 / NSEC_PER_SEC)
> +
>  #else

Oh dear... how many bogus patches are going to be posted today ?


