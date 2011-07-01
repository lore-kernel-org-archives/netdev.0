From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/2] netpoll: Trivial updates
Date: Thu, 30 Jun 2011 20:35:49 -0700
Message-ID: <1309491349.7277.22.camel@Joe-Laptop>
References: <cover.1309482314.git.joe@perches.com>
	 <4E0D3E80.5080209@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E0D3E80.5080209@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-07-01 at 11:26 +0800, Cong Wang wrote:
> =E4=BA=8E 2011=E5=B9=B407=E6=9C=8801=E6=97=A5 09:08, Joe Perches =E5=86=
=99=E9=81=93:
> > cc: WANG Cong<amwang@redhat.com>
> > Joe Perches (2):
> >    netpoll: Remove unused EXPORT_SYMBOLs of netpoll_poll and netpol=
l_poll_dev
> >    netpoll: Remove trivial wrapper function netpoll_poll
> >   include/linux/netpoll.h |    2 --
> >   net/core/netpoll.c      |   13 +++----------
> >   2 files changed, 3 insertions(+), 12 deletions(-)
> I am fine with patch 1/2, but not 2/2, since it is trivial,
> why touch it? With netpoll_poll(), we don't need to explore the
> details of struct netpoll, I think it is nice to have it.

Shrug.  Neither is used.  Keep things minimal.

> BTW, you can kill the export of netpoll_send_skb_on_dev() too.

Not too sure about that.

It's used in netpoll.h by netpoll_send_skb.
It could be called from anywhere.
It's currently called/used by bonding.h.

cheers, Joe
