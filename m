From: =?utf-8?Q?J=F6rn?= Engel <joern@dublin.logfs.org>
Subject: Re: [Regression] r8169: enable 64-bit DMA by default for PCI
	Express devices (v2)
Date: Sat, 27 Mar 2010 07:38:38 +0100
Message-ID: <20100327063838.GB11959@Dublin.logfs.org>
References: <20100315150806.GA15354@Dublin.logfs.org> <20100315151041.GA15667@Dublin.logfs.org> <20100315.115748.13754030.davem@davemloft.net> <51f3faa71003151628g5edc4d7av8916ac76cb337bfe@mail.gmail.com> <20100316083501.GA3489@Dublin.logfs.org> <51f3faa71003161630g69160ea9tc1a2d448682632e5@mail.gmail.com> <51f3faa71003251756h17374375yd3a5d2acee2ffab9@mail.gmail.com> <20100326091234.GA11959@Dublin.logfs.org> <4BAD65A0.7090309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	romieu@fr.zoreil.com
To: Robert Hancock <hancockrwd@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [85.183.11.32] ([85.183.11.32]:52831 "EHLO Dublin.logfs.org"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751326Ab0C0Giq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Mar 2010 02:38:46 -0400
Content-Disposition: inline
In-Reply-To: <4BAD65A0.7090309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 March 2010 19:55:44 -0600, Robert Hancock wrote:
>
> Well, that one's 36 bits, but it's unclear whether that driver would =
=20
> actually be likely to access anything over 4GB. It's possible that =20
> there's just some general problem with 64-bit DMA on that machine.

That may very well be.  I've had trouble using a PCIe card in that
machine as well.  "Solution" was to buy a different computer.  Sad, I
know, but not my money.

> The fact that even stuff like lspci and MII is breaking seems odd, =20
> though. It could be that model of card doesn't like the PCIDAC regist=
er =20
> bit being set (maybe it means something different on that model, or =20
> something).
>
> I suppose a publicly accessible datasheet for these chips is too much=
 to =20
> hope for?

Which chips?

J=EF=BF=BDrn
