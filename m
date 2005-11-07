From: Horms <horms@debian.org>
Subject: Bug#337089: linux-image-2.6.14-1-powerpc: add CONFIG_TCP_CONG_BIC=y
Date: Mon, 7 Nov 2005 15:36:54 +0900
Message-ID: <20051107063654.GJ4780@verge.net.au>
References: <20051102162451.0002CF64E@ibook.free.fr> <20051104032726.GD4708@verge.net.au> <cbec11ac0511041024v5aec928dh@mail.gmail.com>
Reply-To: Horms <horms@debian.org>, 337089@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?UTF-8?Q?Beno=C3=AEt?= Dejean <benoit@placenet.org>,
	337089@bugs.debian.org, NetDev <netdev@vger.kernel.org>
Return-path: <bounce-debian-kernel=glddk-debian-kernel=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.337089.B337089.11313460577545@bugs.debian.org>
To: Ian McDonald <imcdnzl@gmail.com>
Content-Disposition: inline
In-Reply-To: <cbec11ac0511041024v5aec928dh@mail.gmail.com>
List-Post: <mailto:debian-kernel@lists.debian.org>
List-Help: <mailto:debian-kernel-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-kernel-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-kernel-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

On Sat, Nov 05, 2005 at 07:24:41AM +1300, Ian McDonald wrote:
> > > But Debian .config has CONFIG_TCP_CONG_BIC=m (CONFIG_TCP_CONG_*=m) which
> > > makes NewReno default. So this is like a "regression". I'd like debian kernel
> > > to have CONFIG_TCP_CONG_BIC=y provided that one can easily switch to another
> > > algorithm (using /proc/sys/net/ipv4/tcp_congestion_control).
> >
> > could someone please comment on what a good default congestion
> > algorithm setup for distribution kernels is?
> >
> If you want BIC as default then do as suggested here. My personal
> opinion is that is the correct thing to do for a standard
> distribution.

Thanks, the suggestion above will be incporated into the next release.

-- 
Horms
