From: Andrew Grover <andy.grover@gmail.com>
Subject: prequeue still a good idea?
Date: Thu, 28 Apr 2005 11:49:32 -0700
Message-ID: <c0a09e5c05042811492162746@mail.gmail.com>
Reply-To: Andrew Grover <andy.grover@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I came across this comment from include/net/tcp.h tcp_prequeue:

/* Packet is added to VJ-style prequeue for processing in process
 * context, if a reader task is waiting. Apparently, this exciting
 * idea (VJ's mail "Re: query about TCP header on tcp-ip" of 07 Sep 93)
 * failed somewhere. Latency? Burstiness? Well, at least now we will
 * see, why it failed. 8)8)				  --ANK
 */

I'm trying to understand -- is the prequeue really not a win, and if
so, why do we still have it?

Especially with modern tcp csumming HW, its benefit is not clear to
me. The whole point of the prequeue, and calling tcp_v4_do_rcv from
user context, was to speed up *sw* csum, right?

Thanks -- Regards -- Andy
