From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 20:55:50 +0300
Message-ID: <20070220175550.GB26961@2ka.mipt.ru>
References: <200702191913.08125.dada1@cosmosbay.com> <200702201738.19590.dada1@cosmosbay.com> <20070220165907.GB24930@2ka.mipt.ru> <200702201820.27095.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "Michael K. Edwards" <medwards.linux@gmail.com>,
	David Miller <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:59199 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932979AbXBTR5K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 12:57:10 -0500
Content-Disposition: inline
In-Reply-To: <200702201820.27095.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 06:20:26PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> > Hmm, I've just ran following test:
> > 1. created 2^20 hash table.
> > 2. ran in loop (100*(2^20) iterations) following hashes:
> >  a. xor hash (const_ip, const_ip, random_word)
> 
> So what ? to attack me you want to send 100*2^20 packets every minute ?

:) No, I will specially craft 1000 packets which will hist the same
chain.

> Thats nonsense... If you really can send so many packets, My pipe is full 
> whatever I do of received packets. No Algo will protect me, even designed by 
> Einstein.

Did you ever read what I wrote?
It is test, which shows that 
1. jenkins has problems
2. it is two times slower than xor

How to explot problem in a real world is out of that research, but it is
enough to say that it is broken.

> If you look again at route cache, you will see chains length are limited by 
> elasticity factor, that is usually 8... No need to try to reach 100 entries 
> in a chain.
> 
> Yes, I can destroy Russia sending 2^10 nuclear weapons on major cities. You 
> really should build a bunker right now :)

France only has 100 delivery vehicles (about 50 submarines and 50
Mirages) - so no, I will not :)

> Now try to build an attack with 100 packets per second... and I will try to be 
> smart too.

Depending on the end result... Wanna buy me (or suggest) couple of bottles of 
good not expensive french wine? :)

Here is a dump of possible addr/port pairs which end up badly
distributed:

8e363a50:27652 -> c0a80001:20480
8e363a50:35529 -> c0a80001:20480
8e363a50:40919 -> c0a80001:20480
8e363a50:46720 -> c0a80001:20480

they produce the same hash value in the test described above.

-- 
	Evgeniy Polyakov
