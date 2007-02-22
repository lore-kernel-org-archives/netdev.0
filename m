From: kristrev@student.matnat.uio.no
Subject: Copy data from one SKB to another
Date: Thu, 22 Feb 2007 12:59:47 +0100 (CET)
Message-ID: <58989.129.240.228.53.1172145587.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-net@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I am working on optimizing the TCP-code for a certain type of TCP-stream,
and to make one of my optimizations work I need to copy data from one SKB
(the data field of the skb) to another SKB (data field).

Currently I am using memcpy, and it does what it is supposed to, but I am
curious as to if there are any other (potentially faster/more efficient)
ways of doing it. I have checked out the skb_add_data (used when you can
copy data from the msg you are sending into the most recent skb added to
the queue), but from what I can understand it only copies from userspace
into kernelspace (whereas I need to copy kernel-kernel).

Does anyone have any hints, suggestions, solutions or something else they
think might help?

Thanks,
Kristian

