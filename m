From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH]IPv6: fix refcnt of struct ip6_flowlabel
Date: Tue, 25 Oct 2005 17:22:54 +0900 (JST)
Message-ID: <20051025.172254.100422401.yoshfuji@linux-ipv6.org>
References: <435CCF7B.6030907@21cn.com>
	<39e6f6c70510241135p18b018bo896b3565fa5ce87b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanzheng@21cn.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932092AbVJYIWy@vger.kernel.org>
To: acme@ghostprotocols.net
In-Reply-To: <39e6f6c70510241135p18b018bo896b3565fa5ce87b@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <39e6f6c70510241135p18b018bo896b3565fa5ce87b@mail.gmail.com> (at Mon, 24 Oct 2005 16:35:33 -0200), Arnaldo Carvalho de Melo <acme@ghostprotocols.net> says:

> On 10/24/05, Yan Zheng <yanzheng@21cn.com> wrote:
> > Signed-off-by: Yan Zheng <yanzheng@21cn.com>
> >
> >
> > Index: net/ipv6/ip6_flowlabel.c
> > ===================================================================
> > --- linux-2.6.14-rc5/net/ipv6/ip6_flowlabel.c   2005-10-22 10:31:13.000000000 +0800
> > +++ linux/net/ipv6/ip6_flowlabel.c      2005-10-24 19:55:23.000000000 +0800
> > @@ -483,7 +483,7 @@
> >                                                 goto done;
> >                                         }
> >                                         fl1 = sfl->fl;
> > -                                       atomic_inc(&fl->users);
> > +                                       atomic_inc(&fl1->users);
> >                                         break;
> 
> Looks OK to me, Yoshifuji-san, ACK?

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
