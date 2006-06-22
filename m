From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Thu, 22 Jun 2006 13:36:16 +0900 (JST)
Message-ID: <20060622.133616.121412573.yoshfuji@linux-ipv6.org>
References: <20060515.221637.90861876.davem@davemloft.net>
	<200606221205.35161.kelly@au.ibm.com>
	<Pine.LNX.4.64.0606212354420.15426@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kelly@au1.ibm.com, davem@davemloft.net, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:16136 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932791AbWFVEfX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 00:35:23 -0400
To: jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0606212354420.15426@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.64.0606212354420.15426@d.namei> (at Wed, 21 Jun 2006 23:58:56 -0400 (EDT)), James Morris <jmorris@namei.org> says:

> On Thu, 22 Jun 2006, Kelly Daly wrote:
> 
> > +	switch (bp->netchan_buf_proto) {
> > +	case __constant_htons(ETH_P_IP): {
> 
> __constant_htons and friends should not be used in runtime code, only for 
> data being initialized at compile time.

I disagree.  For "case," use __constant_{hton,ntoh}{s,l}(), please.

--yoshfuji
