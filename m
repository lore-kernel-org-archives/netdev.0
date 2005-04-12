From: Baruch Even <baruch@ev-en.org>
Subject: TCP performance drop 2.6.6->2.6.7
Date: Tue, 12 Apr 2005 23:18:35 +0100
Message-ID: <425C493B.5040206@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I'm trying to port my H-TCP and SACK improvements to 2.6.11, but I seem 
to hit performance problems that are unrelated to what I worked on so far.

My tests show that between 2.6.6 and 2.6.7 the TCP performance dropped 
considerably.

The setup for the tests, vanilla kernels, dummynet with 100 Mbit/s and 
40ms rtt using the BIC protocol. No patches applied whatsoever.

iperf tests for 2.6.6 get about 90Mbit/s while 2.6.7 gets 30Mbit/s.

I was wondering if someone can think of a reason why this happens?

Is there a way to get the different network related patches between 
these two versions? I don't have access to bk to get it myself.

Baruch
