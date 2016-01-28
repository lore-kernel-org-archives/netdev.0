From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH V2] netfilter: h323: avoid potential attack
Date: Thu, 28 Jan 2016 14:15:57 +0000
Message-ID: <20160128141557.74ad75f0@lxorguk.ukuu.org.uk>
References: <1453971597-4811-1-git-send-email-zhouzhouyi@gmail.com>
	<1453985821.7627.17.camel@edumazet-glaptop2.roam.corp.google.com>
	<a703ec.53db.152885f2292.Coremail.yizhouzhou@ict.ac.cn>
	<1453989650.7627.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Zhouyi Zhou <yizhouzhou@ict.ac.cn>,
	Zhouyi Zhou <zhouzhouyi@gmail.com>, pablo@netfilter.org,
	kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:58496 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617AbcA1OQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 09:16:35 -0500
In-Reply-To: <1453989650.7627.30.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Jan 2016 06:00:50 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Thu, 2016-01-28 at 21:14 +0800, Zhouyi Zhou wrote:
> 
> > My patch is intend to prevent kernel panic, to prevent reading garbage
> > or read data from a prior frame and leak secrets, the prototypes of the 
> > get_h2x5_addr functions and the functions that call get_h2x5_addr should
> > be changed, should we do this?   
> 
> In term of security, panics are better than allowing attacker to read
> data from other people, like a password.
> 
> BTW, are you able to trigger any panic ?

We have a smattering of panics in this code in bugzilla going back years.

https://bugzilla.kernel.org/show_bug.cgi?id=12473

etc

Alan
