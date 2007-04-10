From: Robin Getz <rgetz@blackfin.uclinux.org>
Subject: Re: [PATCH] CONFIG_PACKET_MMAP should depend on MMU
Date: Tue, 10 Apr 2007 19:52:04 -0400
Message-ID: <200704101952.05380.rgetz@blackfin.uclinux.org>
References: <200704091146.32346.rgetz@blackfin.uclinux.org> <1176112223.17975.8.camel@roc-desktop> <9561.1176209728@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bryan.wu@analog.com, "Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	waltje@uwalt.nl.mugnet.org, "Aubrey Li" <aubreylee@gmail.com>,
	netdev@vger.kernel.org, "Andrew Morton" <akpm@osdl.org>,
	"Linux Kernel" <linux-kernel@vger.kernel.org>
To: "David Howells" <dhowells@redhat.com>, uaca@alumni.uv.es
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:42301 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161104AbXDJXub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 19:50:31 -0400
In-Reply-To: <9561.1176209728@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue 10 Apr 2007 08:55, David Howells pondered:
> Looking at alloc_pg_vec() in af_packet.c, I will place my bets on the
> latter case.  I don't know that this is a problem; it depends on how things
> work, and that I don't know offhand.  If someone can give me a simple test
> program, I would be able to evaluate it better.

Hmm - the only think I have used in the past is tcpdump/libpcap from
http://public.lanl.gov/cpw/

Documentation/networking/packet_mmap.txt also seems to be a little dated, but 
does have some code snippets if you wanted to make something lightweight...

Does anyone else on netdev have a small test app?

-Robin
