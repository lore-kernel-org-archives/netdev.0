From: Cypher Wu <cypher.w@gmail.com>
Subject: Re: Kernel rwlock design, Multicore and IGMP
Date: Mon, 15 Nov 2010 19:18:38 +0800
Message-ID: <AANLkTinzRm_5WW5HwxzXqZZD4255GDpR4yzELqz66Dfn@mail.gmail.com>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>
	<1289489007.17691.1310.camel@edumazet-laptop>
	<AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com>
	<ZXmP8hjgLHA.4648@exchange1.tad.internal.tilera.com>
	<4CDF1945.8090101@tilera.com>
	<AANLkTind92uwcigzmDn8yn9a22exDy7zcreGQ5-6NLV-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: =?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTind92uwcigzmDn8yn9a22exDy7zcreGQ5-6NLV-@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In that post I want to confirm another thing: if we join/leave on
different cores that every call will start the timer for IGMP message
using the same in_dev->mc_list, could that be optimized?

-- 
Cyberman Wu
http://www.meganovo.com
