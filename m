From: "Thomas 'Dent' Mirlacher" <dent@cosy.sbg.ac.at>
Subject: Re: packet socket can't steal packets
Date: Tue, 7 May 2002 20:16:27 +0200 (MET DST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.05.10205072013200.9591-100000@mausmaki.cosy.sbg.ac.at>
References: <Pine.OSF.4.30.0205072042410.30796-100000@kosh.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Dmitrii Tisnek <dima@cc.hut.fi>
In-Reply-To: <Pine.OSF.4.30.0205072042410.30796-100000@kosh.hut.fi>
List-Id: netdev.vger.kernel.org

On Tue, 7 May 2002, Dmitrii Tisnek wrote:

> hey, I've been trying to change certain network packet mangling software
> such that it would not need a kernel module, and it seems to me that,
> unfortunately there's no way to make packet socket "steal" packets it
> deliveres to the user mode.
> 
> The behaviour I see is it gives userland a copy and give the native
> network stack a copy.

right - take a look at net/core/dev.c netif_receive_skb.

> unless I missed something, perhaps there could be an ioctl/setsockopt
> which would turn this behaviour into "pass packet to user mode or drop
> altogether" that would never result in network stack getting a packet
> directly.

well, that would be nice for certain applications, but wouldn't it
also be a security problem?

... well there would be a way how you could implement this kind of
feature now, but you need to write a module also :(

	++dent

-- 
in some way i do, and in some way i don't.
