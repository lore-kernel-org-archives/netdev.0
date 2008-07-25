From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Fri, 25 Jul 2008 17:34:26 +0200
Message-ID: <200807251734.27743.thomas.jarosch@intra2net.com>
References: <47EA0DAB.7080205@securenet.de> <200807251500.05527.thomas.jarosch@intra2net.com> <Pine.LNX.4.64.0807251613230.11302@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	"=?iso-8859-15?q?D=E2niel?= Fraga" <fragabr@gmail.com>,
	David Miller <davem@davemloft.net>
To: "Ilpo =?iso-8859-15?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs02.intra2net.com ([81.169.173.116]:39566 "EHLO
	rs02.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807AbYGYPec convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 11:34:32 -0400
In-Reply-To: <Pine.LNX.4.64.0807251613230.11302@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo,

On Friday, 25. July 2008 16:06:04 Ilpo J=E4rvinen wrote:
> I guess the patch below would be enough in itself to create the desir=
ed
> effect (though "desired" is hardly a negative enough word to describe=
 a
> workaround of this kind).=20

Yeah, the result feels good enough for me. Here's the latest tcpdump
before I run out of good filenames for the dumps:
http://www.intra2net.com/de/download/tcpdump/tcp_frto_combined_patch.ta=
r.bz2

> Ie., in the worst case 6.8% of your link's capacity was wasted during=
 the
> transfer due to inefficiency cause by that middlebox, not counting th=
e
> under-utilization that occurs both because of a small window or a wai=
t for
> RTOs, not bad result at all... :-D

IIRC our outbound box does traffic shaping, so some percents are to be=20
accounted to packets being dropped to slow down the connection a bit=20
if they come (in) too fast.

Anyway, we now just have to flip a coin if this gets into the kernel
or not :-) I really hope this could save someone from doing
the same debug session all over again...

Thanks for the hard work you put into debugging this.

Thomas
