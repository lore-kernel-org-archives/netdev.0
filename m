From: Brice Goglin <Brice.Goglin@inria.fr>
Subject: Re: DCA/IOAT problem
Date: Mon, 26 Jan 2009 21:24:01 +0100
Message-ID: <497E1BE1.4020301@inria.fr>
References: <497DF609.9000600@chelsio.com> <497E13B8.9040803@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iona.labri.fr ([147.210.8.143]:41826 "EHLO iona.labri.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751470AbZAZUpj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2009 15:45:39 -0500
In-Reply-To: <497E13B8.9040803@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pawe=C5=82 Staszewski wrote:
> ioatdma 0000:00:08.0: DCA is disabled in BIOS
>
> Why DCA is not working (or workink but no info about in ioat)

See above in dmesg: It's disabled in BIOS. If the BIOS doesn't have an
option to enable DCA, you need to talk to your vendor. Or you can try
changing registers on the chipset manually...

Brice

