From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Fri, 25 Jul 2008 15:00:03 +0200
Message-ID: <200807251500.05527.thomas.jarosch@intra2net.com>
References: <47EA0DAB.7080205@securenet.de> <200807181602.42338.thomas.jarosch@intra2net.com> <Pine.LNX.4.64.0807231821170.13775@wrl-59.cs.helsinki.fi>
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
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0807231821170.13775@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ilpo,

On Friday, 25. July 2008 12:00:29 Ilpo J=E4rvinen wrote:
> [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround

The latest patch works quite good. I accidentally had your
previous patch applied, too, which gave even better results.
Though I don't know enough about the gory details of FRTO
if this effectivly disables it...

Here are two fresh tcpdumps, one with the last patch only
and one which also includes your previous patch:
http://www.intra2net.com/de/download/tcpdump/tcp_frto_highmark_patch.ta=
r.bz2

> ...
> This is probably due to some broken middlebox but that's purely
> speculation since the details of the not named ISP's (you can
> find some hint in Patrick's blog though ;-)) equipment are not
> available to us.

LOL, this reminds me about the post on kernel.org from 2007-03-01:
"Kudos ... to Hewlett Packard for building a machine that can take the =
beating=20
of an unnamed shipping company and keep on ticking".=20

Just think of "unnamed" while looking at the images of the broken serve=
r ;-)

Have a nice weekend,
Thomas
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
