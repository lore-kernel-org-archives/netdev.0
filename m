From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH] net: ipv4: route: fixed a coding style issues net:
 ipv4: tcp: fixed a coding style issues
Date: Thu, 20 Dec 2012 07:23:59 -0800
Message-ID: <1356017039.21834.2819.camel@edumazet-glaptop>
References: <1355990910-3688-1-git-send-email-hasko.stevo@gmail.com>
	 <50D2FF86.3000603@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stefan Hasko <hasko.stevo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:50540 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917Ab2LTPYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 10:24:03 -0500
In-Reply-To: <50D2FF86.3000603@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-20 at 13:07 +0100, Nicolas Dichtel wrote:
> Le 20/12/2012 09:08, Stefan Hasko a =C3=A9crit :

> > +				"out_hlist_search\n");
> checkpatch will warn you about this one, something like:
> "WARNING: quoted string split across lines".
> Not breaking such line ease to grep the pattern.


Yes.

Could we please leave this file as is for at least 2 years ?

We had a lot of recent changes and probable fixes are expected.

Such "coding style" patches are a real pain when trying to fix bugs,
especially dealing with stable/old kernels.

Thanks
