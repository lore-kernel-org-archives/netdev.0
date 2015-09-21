From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 7/7] 8139cp: Avoid gratuitous writes to TxPoll register
 when already running
Date: Mon, 21 Sep 2015 22:54:40 +0200
Message-ID: <20150921205440.GA4559@electric-eye.fr.zoreil.com>
References: <1442843991.7367.4.camel@infradead.org>
 <1442844340.7367.19.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40323 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752306AbbIUUza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 16:55:30 -0400
Content-Disposition: inline
In-Reply-To: <1442844340.7367.19.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse <dwmw2@infradead.org> :
[...]
> I'm actually having second thoughts about this one since realising th=
at
> QEMU doesn't implement it correctly. The workaround isn't *that* horr=
id
> but it's not clear it's enough of a performance win =E2=80=94 or whet=
her it's
> entirely necessary for catching my TX stall.

It don't indulge in this kind of fetish but I'm fine with people who wa=
nt
to play with QEMU 8139cp emulation where they could use virtio. They sh=
ould
imvho realize that it's their job to fix QEMU 8139cp emulation, not the
other way around.

Please keep things sane (*cough*) and avoid the qemu workaround.

--=20
Ueimor
