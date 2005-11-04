From: Ian McDonald <imcdnzl@gmail.com>
Subject: Bug#337089: linux-image-2.6.14-1-powerpc: add CONFIG_TCP_CONG_BIC=y
Date: Sat, 5 Nov 2005 07:24:41 +1300
Message-ID: <cbec11ac0511041024v5aec928dh@mail.gmail.com>
References: <20051102162451.0002CF64E@ibook.free.fr>
	 <20051104032726.GD4708@verge.net.au>
Reply-To: Ian McDonald <imcdnzl@gmail.com>, 337089@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?Q?Beno=C3=AEt?= Dejean <benoit@placenet.org>,
	337089@bugs.debian.org, NetDev <netdev@vger.kernel.org>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.337089.B337089.11311286841553@bugs.debian.org>
To: Horms <horms@debian.org>
In-Reply-To: <20051104032726.GD4708@verge.net.au>
Content-Disposition: inline
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

> > But Debian .config has CONFIG_TCP_CONG_BIC=3Dm (CONFIG_TCP_CONG_*=3Dm) =
which
> > makes NewReno default. So this is like a "regression". I'd like debian =
kernel
> > to have CONFIG_TCP_CONG_BIC=3Dy provided that one can easily switch to =
another
> > algorithm (using /proc/sys/net/ipv4/tcp_congestion_control).
>
> could someone please comment on what a good default congestion
> algorithm setup for distribution kernels is?
>
If you want BIC as default then do as suggested here. My personal
opinion is that is the correct thing to do for a standard
distribution.

If it is an experimental distribution then turn on tcp advanced
congestion control and build the rest (except for BIC) as modules.

Ian
--
Ian McDonald
http://wand.net.nz/~iam4
WAND Network Research Group
University of Waikato
New Zealand
