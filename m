From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCHSET] Mobile IPv6 for 2.5.43
Date: Fri, 01 Nov 2002 12:27:58 +0900 (JST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20021101.122758.809131116.yoshfuji@linux-ipv6.org>
References: <20021017162624.GC16370@morphine.tml.hut.fi>
	<20021031.174442.846937513.takamiya@po.ntts.co.jp>
	<20021031104146.GA18786@morphine.tml.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: takamiya@po.ntts.co.jp, davem@redhat.com, kuznet@ms2.inr.ac.ru,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	pekkas@netcore.fi, torvalds@transmeta.com, jagana@us.ibm.com,
	yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: ajtuomin@morphine.tml.hut.fi
In-Reply-To: <20021031104146.GA18786@morphine.tml.hut.fi>
List-Id: netdev.vger.kernel.org

In article <20021031104146.GA18786@morphine.tml.hut.fi> (at Thu, 31 Oct 2002 12:41:46 +0200), Antti Tuominen <ajtuomin@morphine.tml.hut.fi> says:

> > (4) Processing Mobility Header
> > 	How about using ip6_txoptions and hdrproc_lst?
> > 	Because Mobility header is an extension header, we think it is
> > 	reasonable way to handle it in ipv6_parse_exthdrs().
> 
> No.  We did this back in Draft 15, when all the mobility stuff was
> destination options.  Mobility Header is not an extension header, but
> rather a final protocol.  Only Home Address Option is an extension
> header and is handled in ipv6/exthdrs.c.  What is the problem with
> this?

This is not so strong request here at this moment.

--yoshfuji
