From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/2] netpoll: Trivial updates
Date: Thu, 30 Jun 2011 21:03:59 -0700
Message-ID: <1309493039.7277.26.camel@Joe-Laptop>
References: <cover.1309482314.git.joe@perches.com>
	 <4E0D3E80.5080209@redhat.com> <1309491349.7277.22.camel@Joe-Laptop>
	 <4E0D43C3.5090502@redhat.com> <1309492522.7277.25.camel@Joe-Laptop>
	 <4E0D4651.7000005@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E0D4651.7000005@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-07-01 at 12:00 +0800, Cong Wang wrote:
> =E4=BA=8E 2011=E5=B9=B407=E6=9C=8801=E6=97=A5 11:55, Joe Perches =E5=86=
=99=E9=81=93:
> > On Fri, 2011-07-01 at 11:49 +0800, Cong Wang wrote:
> >> =E4=BA=8E 2011=E5=B9=B407=E6=9C=8801=E6=97=A5 11:35, Joe Perches =E5=
=86=99=E9=81=93:
> >>>> BTW, you can kill the export of netpoll_send_skb_on_dev() too.
> >>> Not too sure about that.
> >>> It's used in netpoll.h by netpoll_send_skb.
> >>> It could be called from anywhere.
> >>> It's currently called/used by bonding.h.
> > Read what I wrote.
> > Look up one level at where it's used by netpoll.h.
> Then move netpoll_send_skb(), export it instead of netpoll_send_skb_o=
n_dev()...

Submit that if you choose.
