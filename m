From: "Michael K. Edwards" <medwards.linux@gmail.com>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 11:44:41 -0800
Message-ID: <f2b55d220702201144r76e62c6cxfcb840d43881e859@mail.gmail.com>
References: <200702191913.08125.dada1@cosmosbay.com>
	 <200702201955.15567.dada1@cosmosbay.com>
	 <20070220190634.GA12193@2ka.mipt.ru>
	 <200702202017.31965.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"David Miller" <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: "Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:29438 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030343AbXBTTon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 14:44:43 -0500
Received: by an-out-0708.google.com with SMTP id c5so416240anc
        for <netdev@vger.kernel.org>; Tue, 20 Feb 2007 11:44:42 -0800 (PST)
In-Reply-To: <200702202017.31965.dada1@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All right, Eric, you and me so clevvah, let's embarrass our own selves
designing this thing in public instead of picking on poor Evgeniy.
Which would you rather RCU, a 2-left hash or a splay tree?  2-left
hash gets you excellent occupation fraction before the first real
collision, so you can be utterly stupid about collisions in the second
hash table (just toss all double collisions in an overflow radix
tree).  Splay tree is a lot bigger bite to chew initially, but it gets
you a hot set that's at least sometimes warm in cache, and it's easier
to think about how to RCU it, and it doubles as a priority queue.  You
pick.

Cheers,
- Michael
