From: Dmitrii Tisnek <dima@cc.hut.fi>
Subject: Re: packet socket can't steal packets
Date: Tue, 7 May 2002 21:28:59 +0300 (EET DST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.OSF.4.30.0205072125330.30796-100000@kosh.hut.fi>
References: <Pine.GSO.4.05.10205072013200.9591-100000@mausmaki.cosy.sbg.ac.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: "Thomas 'Dent' Mirlacher" <dent@cosy.sbg.ac.at>
In-Reply-To: <Pine.GSO.4.05.10205072013200.9591-100000@mausmaki.cosy.sbg.ac.at>
List-Id: netdev.vger.kernel.org

On Tue, 7 May 2002, Thomas 'Dent' Mirlacher wrote:
>
> > unless I missed something, perhaps there could be an ioctl/setsockopt
> > which would turn this behaviour into "pass packet to user mode or drop
> > altogether" that would never result in network stack getting a packet
> > directly.
>
> well, that would be nice for certain applications, but wouldn't it
> also be a security problem?

no.

read-only access to network traffic already requires priviledges.
and theres' already a way to insert packets via socket send/write.

all I'm proposing is a way to "delete" packets too.

cheers, dima.
