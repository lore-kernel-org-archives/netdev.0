From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Wed, 16 Jul 2008 10:07:56 +0200
Message-ID: <200807161007.57367.thomas.jarosch@intra2net.com>
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

Terve Ilpo,

On Tuesday, 15. July 2008 22:17:47 Ilpo J=E4rvinen wrote:
> > I can easily reproduce the problem, so how do we go from here?
>
> FRTO in 2.6.24.y is broken, I recently fixed couple of things in FRTO=
,
> late 2.6.25.y or 2.6.26 should be used to have all the fixes. If you =
can
> reproce with either one, please tcpdump it (I just returned, was coup=
le of
> weeks away, so I'm slowly catching up what has happened in between he=
re).
> ...I guess somebody had dumped at least 2.6.24.y but that's not
> interesting due to known (and fixed) bugs with FRTO.

I tried 2.6.25.10 without luck. I have a git "master" tree from yesterd=
ay=20
which is also stalling for some seconds around ~220kb and then recoveri=
ng.=20
The connection completly stalls at around ~1.3mb. I'll send you a tcpdu=
mp
in private soon as it's going to be rather big for the mailinglist.

Thomas
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
