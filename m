From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Enhance AF_PACKET implementation to not require high
 order contiguous memory allocation
Date: Mon, 25 Oct 2010 21:53:49 -0400
Message-ID: <20101026015349.GA31631@hmsreliant.think-freely.org>
References: <E1PAVIx-0001qL-EB@smtp.tuxdriver.com>
 <1288045856.3296.19.camel@edumazet-laptop>
 <20101025233558.GA30118@hmsreliant.think-freely.org>
 <20101025.164646.104054845.davem@davemloft.net>
 <AANLkTinxe7M-_bHdhA-jrW2gBtGLCXkBasSPi7RaFDi-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, jpirko@redhat.com
To: Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58652 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754079Ab0JZByB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 21:54:01 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTinxe7M-_bHdhA-jrW2gBtGLCXkBasSPi7RaFDi-@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 25, 2010 at 05:48:33PM -0700, Maciej =C5=BBenczykowski wrot=
e:
> This is http://bugzilla.redhat.com/637619
>=20
> I'm the original reporter and I haven't yet fully vetted / tested the
> patch (not directly related to my job and all that).
>=20
I validated it.  You reported that tcpdump startup caused your system t=
o
'freeze'.  I managed to recreate that situation, as observed by my syst=
em
becomming unresponsive on the console, and validated that that situatio=
n did not
occur when this patch was applied.

Neil

