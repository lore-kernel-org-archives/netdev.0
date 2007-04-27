From: David Howells <dhowells@redhat.com>
Subject: Re: linux-2.6.21-ga205752d build #249 failed in net/rxrpc/rxkad.o:(.bss+0x0): multiple definition of `rxrpc_debug'
Date: Sat, 28 Apr 2007 00:19:30 +0100
Message-ID: <31645.1177715970@redhat.com>
References: <200704272124.29189.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Toralf =?us-ascii?Q?=3D=3Fiso-8859-1=3Fq=3FF=3DF6rster=3F=3D?=
	<toralf.foerster@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36329 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757889AbXD0XTn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 19:19:43 -0400
In-Reply-To: <200704272124.29189.toralf.foerster@gmx.de> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Toralf F=F6rster <toralf.foerster@gmx.de> wrote:

> net/rxrpc/rxkad.o:(.bss+0x0): multiple definition of `rxrpc_debug'
> net/rxrpc/af-rxrpc.o:(.bss+0x10): first defined here

I've submitted a patch that fixes that already.

	Subject: [PATCH 2/3] AF_RXRPC/AFS: Arch-specific fixes

Though DaveM isn't keen on the way I did it, so there'll be another pat=
ch to
change it.

What I intend to do, I think, is to drop the #define of rxrpc_debug ->
rxkad_debug and also to drop the definition of rxrpc_debug in rxkad.c. =
 The
rxrpc_debug in af_rxrpc.c can then be EXPORT_SYMBOL'd and shared betwee=
n the
two related modules.

Unfortunately, it'll have to wait till later today to give me a chance =
to test
it.

David
