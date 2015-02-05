From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] pkt_sched: fq: better control of DDOS
 traffic
Date: Wed, 04 Feb 2015 21:24:42 -0800
Message-ID: <1423113882.31870.30.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1422626772.21689.90.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1422984739.907.25.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150204.202245.1889006308590918014.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:51936 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910AbbBEFYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 00:24:44 -0500
Received: by mail-pa0-f47.google.com with SMTP id lj1so7610971pab.6
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 21:24:44 -0800 (PST)
In-Reply-To: <20150204.202245.1889006308590918014.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-02-04 at 20:22 -0800, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 03 Feb 2015 09:32:19 -0800
> 
> > +	if (tb[TCA_FQ_ORPHAN_MASK])
> > +		q->orphan_mask = nla_get_u32(tb[TCA_FQ_ORPHAN_MASK]);
> 
> This doesn't build, the header file changes that add TCA_FQ_ORPHAN_MASK
> are missing from your patch.

Arg.. sorry for that. Will send a v3
