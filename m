From: Baruch Even <baruch@ev-en.org>
Subject: ixgb problem
Date: Sun, 06 Mar 2005 19:06:23 +0000
Message-ID: <422B54AF.4060401@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I'm trying to get a high-speed network setup and am having a problem 
with the ixgb driver.

The setup I'm running is: s1 -- Cisco -- s2

s1 and s2 are identical Dell 1U servers, each having two onboard 1GbE 
cards, one extra 1GbE card and one 10GbE card. The GbE are all copper 
and the 10GbE is fiber.

The Cisco is a 6503 with a 10GbE line card with two ports. It also has a 
1GbE line card used to connect to another set of machines.

I'm running a test of iperf with a window of 16MB, at first the 
performance shows about 3.2Gbps rate (which sucks by itself, but that's 
another issue), after some time, usually 30-40 seconds, but sometimes 
100 seconds, the performance drops to almost nothing, about 60Kbps.

I have tried it on 2.6.11 and 2.6.11 with the latest snapshot of Jeff 
Garzik net drivers (2.6.11-netdev1.patch.bz2). It happens in both of them.

I have tried with an without NAPI, there is no noticeable change.

Is it known? What can I do to help debug this?

Baruch
