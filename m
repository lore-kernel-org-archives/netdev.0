From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: sched: shrink struct qdisc_skb_cb to 28 bytes
Date: Thu, 18 Sep 2014 13:31:44 -0700
Message-ID: <1411072304.7106.287.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1402338773-5996-1-git-send-email-_govind@gmx.com>
	 <1402338773-5996-2-git-send-email-_govind@gmx.com>
	 <CAE9FiQW+Rv4o9Pc1J9hyqgW1WrhEANKEXH6zYQc2NQqeMbAcvA@mail.gmail.com>
	 <alpine.LNX.2.03.1406261159071.1438@ws.cisco>
	 <CAJZOPZJ7+n0t1LCqaa3JCBByRw=f_Tp6rk8vm0ZnCzmtKFKX_g@mail.gmail.com>
	 <1411052525.7106.269.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140918092628.566eae2b@urahara>
	 <1411057934.7106.275.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411063227.7106.280.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411063655.4290.18.camel@joe-AO725>
	 <1411067679.7106.283.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411068671.4290.24.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Yinghai Lu <yinghai@kernel.org>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>, ssujith@cisco.com,
	gvaradar@cisco.com, "Christian Benvenuti (benve)" <benve@cisco.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:55083 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757345AbaIRUbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 16:31:46 -0400
Received: by mail-pd0-f182.google.com with SMTP id w10so2153425pde.27
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 13:31:45 -0700 (PDT)
In-Reply-To: <1411068671.4290.24.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-18 at 12:31 -0700, Joe Perches wrote:

> I don't mind the const argument, but casting
> the return to non-const seems like poor form.

This is the current way to do this, even if we do not like it.

C does not allow to have the same function name for different
parameters, there is nothing we can do about it at this moment.

->

static inline const struct ipoib_cb *ipoib_skb_cb(const struct sk_buff *skb)

static inline struct ipoib_cb *ipoib_skb_cb(struct sk_buff *skb)
