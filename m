From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Thu, 25 Jan 2007 17:13:57 -0500
Message-ID: <45B92BA5.1050505@hp.com>
References: <20070119212314.GA10748@hmsreliant.homelinux.net> <20070120.080507.25118874.yoshfuji@linux-ipv6.org> <20070122181528.GD21059@hmsreliant.homelinux.net> <20070123.091820.104515696.yoshfuji@linux-ipv6.org> <20070123205118.GC582@hmsreliant.homelinux.net> <1169690087.23312.7.camel@w-sridhar2.beaverton.ibm.com> <20070125133340.GA8891@hmsreliant.homelinux.net> <45B8E60B.7080809@hp.com> <20070125194500.GB8891@hmsreliant.homelinux.net> <45B910B3.5000809@hp.com> <20070125212651.GB12136@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	=?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kg?=
	 =?UTF-8?B?LyDlkInol6Toi7HmmI4=?= <yoshfuji@linux-ipv6.org>,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, kaber@coreworks.de, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:45960 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030625AbXAYWN7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jan 2007 17:13:59 -0500
In-Reply-To: <20070125212651.GB12136@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Neil

> 
> I prefer to be more explicit in my order of operation, but that does seem more
> consistent with the prevaling style.  New patch attached.
> 

Looks good to me.

One question thought.  What causes the stack to send via Default Router instead
of sending an NS (Section 3.2).  I see there is code to prevent sending NS from
the optimistic address, but I see nothing that would send this packet to a default
router.  This might be buried somewhere in the routing code, but I just can't see it.


Thanks
-vlad
