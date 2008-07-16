From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Wed, 16 Jul 2008 11:03:06 +0200
Message-ID: <200807161103.07821.thomas.jarosch@intra2net.com>
References: <47EA0DAB.7080205@securenet.de> <200807151810.45942.thomas.jarosch@intra2net.com> <Pine.LNX.4.64.0807152312080.6254@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	"=?iso-8859-15?q?D=E2niel?= Fraga" <fragabr@gmail.com>
To: "Ilpo =?iso-8859-15?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0807152312080.6254@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, 15. July 2008 22:17:47 Ilpo J=E4rvinen wrote:
> FRTO in 2.6.24.y is broken, I recently fixed couple of things in FRTO=
,
> late 2.6.25.y or 2.6.26 should be used to have all the fixes. If you =
can
> reproce with either one, please tcpdump it

As the dumps are really big, I uploaded them to a temporary space.
Included are two tcpdumps of stalling connections using git "master".
The first one stalls around ~1.3mb, the second one around ~4mb.

Get it from here:
http://www.intra2net.com/de/download/tcpdump/tcp_frto_tcpdumps.tar.bz2

There is another box in front of my test system doing NAT
which is running 2.6.24.7. I've tested with and without tcp_frto
on that box to make sure it's not FRTO related.

I've also included a tcpdump with FRTO disabled, so you can see
the connection is actually working. Just by looking at the packet flow
while tracing the connection looks much smoother without FRTO
and doesn't stall for seconds here and there.

Cheers,
Thomas

--=20
Address (better: trap) for people I really don't want to get mail from:
jessica.hope@cactusamerica.com
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
