From: Dmitrii Tisnek <dima@cc.hut.fi>
Subject: packet socket can't steal packets
Date: Tue, 7 May 2002 21:02:31 +0300 (EET DST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.OSF.4.30.0205072042410.30796-100000@kosh.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <owner-netdev@oss.sgi.com>
To: <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

hey, I've been trying to change certain network packet mangling software
such that it would not need a kernel module, and it seems to me that,
unfortunately there's no way to make packet socket "steal" packets it
deliveres to the user mode.

The behaviour I see is it gives userland a copy and give the native
network stack a copy.

unless I missed something, perhaps there could be an ioctl/setsockopt
which would turn this behaviour into "pass packet to user mode or drop
altogether" that would never result in network stack getting a packet
directly.

I realise same functionality can be achieved through netfilter QUEUE
command, but that doesn't seem as nice.

cheers, dima
