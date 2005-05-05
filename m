From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/3] add open iscsi netlink interface to iscsi
 transport class
Date: Thu, 05 May 2005 20:55:30 +0900 (JST)
Message-ID: <20050505.205530.107537707.yoshfuji@linux-ipv6.org>
References: <20050505.185503.78606493.yoshfuji@linux-ipv6.org>
	<E1DTehn-0005gJ-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michaelc@cs.wisc.edu, linux-scsi@vger.kernel.org,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <linux-scsi-owner@vger.kernel.org>
To: herbert@gondor.apana.org.au
In-Reply-To: <E1DTehn-0005gJ-00@gondolin.me.apana.org.au>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <E1DTehn-0005gJ-00@gondolin.me.apana.org.au> (at Thu, 05 May 2005 21:39:47 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org> wrote:
> > In article <42798AC1.2010308@cs.wisc.edu> (at Wed, 04 May 2005 19:53:53 -0700), Mike Christie <michaelc@cs.wisc.edu> says:
> > 
> >> +struct iscsi_uevent {
> > :
> >> +} __attribute__ ((aligned (sizeof(unsigned long))));
> > 
> > I think it'd be better to use sizeof(uint64_t) or something.
> 
> Is there a benefit in aligning on 64-bit boundaries for 32-bit platforms?

Well, this if for avoiding inconsistency between kernel and userspace.
If you use unsigned long, sizeof(unsigned long) may be inconssitent
between kernel and userland like this:
  kernel:    sizeof(unsigned long) == 8
  userspace: sizeof(unsigned long) == 4

--yoshfuji
