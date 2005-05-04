From: Meelis Roos <mroos@linux.ee>
Subject: Re: icmp_unreachable uses wrong ip
Date: Wed, 04 May 2005 10:03:45 +0300
Message-ID: <E1DTDv7-0003vR-DS@rhn.tartu-labor>
References: <4276A400.2050306@trash.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <4276A400.2050306@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

PM> Your patch can't guarantee that the address used is the same that was
PM> used as nexthop by the previous hop in the path when multiple addresses
PM> are configured on the incoming interface. So I don't think it achieves
PM> much of your goal of making debugging complicated topologies easier.

Nevertheless this patch seems to be the most logical thing to do and is
_much_ better than current state IMHO. Principle of least surprise.

-- 
Meelis Roos
