From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Tue, 10 Sep 2002 18:55:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D7E2407.6060209@colorfullife.com>
References: <3D78F55C.4020207@colorfullife.com>	<20020906.113829.65591342.davem@redhat.com>	<3D790499.8020501@colorfullife.com>	<20020906.123428.28085660.davem@redhat.com> <15741.57164.402952.136812@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, haveblue@us.ibm.com, hadi@cyberus.ca,
   netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
 >
 > Anyway. A tulip NAPI variant added mitigation when we reached "some
 > load" to  avoid the static interrupt delay. (Still keeping things
 > pretty simple):
 >
 > Load   "Mode"
 > -------------------
 > Lo  1) RxIntDelay=0
 > Mid 2) RxIntDelay=fix (When we had X pkts on the RX ring)
 > Hi  3) Consecutive polling. No RX interrupts.
 >
Sounds good.

The difficult part is when to go from Lo to Mid. Unfortunately my tulip 
card is braindead (LC82C168), but I'll try to find something usable for 
benchmarking

In my tests with the winbond card, I've switched at a fixed packet rate:

< 2000 packets/sec: no delay
 > 2000 packets/sec: poll rx at 0.5 ms



--
	Manfred
