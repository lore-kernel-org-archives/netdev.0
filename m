From: Rick Jones <rick.jones2@hp.com>
Subject: Re: tune back idle cwnd closing?
Date: Thu, 27 Apr 2006 14:12:32 -0700
Message-ID: <445133C0.9080808@hp.com>
References: <444E31D9.1010705@psc.edu>	<20060426.144540.39973302.davem@davemloft.net>	<445103B5.2090603@psc.edu> <20060427.131921.79333703.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, zach.brown@oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:62658 "EHLO palrel13.hp.com")
	by vger.kernel.org with ESMTP id S1751679AbWD0VMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 17:12:35 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060427.131921.79333703.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

having looked now at both 2861 and the 99 paper it references I see lots 
of "may's" "mights" and "belief" but nothing "real world."

the CWV vs non CWV was done against a TCP that did indeed reset cwnd 
after an RTT of idle, so it wasn't showing reset at idle versus no reset 
at idle.  just CWV's less draconian (?) reset than the non CWV stack.

the experimental validation in the 99 paper was still a simulation using 
dummynet and a number of buffers rather smaller than what modem banks 
were offering at the time, and it was for a modem, rather than any other 
sort of link. and when they did use a real modem, the buffering in the 
modem bank seems to have made the whole thing moot.

there was nothing about effect on intranets, or high-speed long hauls or 
any of that.


what that means wrt having a sysctl to enable/disable functionality 
still listed as experimental i'm not sure

rick jones
