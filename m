From: Stephen Hemminger <shemminger@osdl.org>
Subject: Hang when testing with AMD64 with Tg3
Date: Mon, 04 Oct 2004 17:11:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096935071.22155.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>, davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Doing simple iperf test on new opteron with tg3 against existing Xeon
system.  I am seeing something wierd, the connection hangs right away.
Is this a TSO bug.  

Sender: BK latest (2.6.9-rc3) Tg3 (XX.YY.250.3)
Receiver: BK + netdev(jeffm) + dave's latest e100 (XX.YY.1.73)

Both machines are directly connected with a netgear 100mbit switch.

16:59:30.726551 IP XX.YY.250.3.32948 > XX.YY.1.73.5001: S 4113740578:4113740578(0) win 5840 <mss 1460,sackOK,timestamp 4233878 0,nop,wscale 2>
16:59:30.726574 IP XX.YY.1.73.5001 > XX.YY.250.3.32948: S 4117129705:4117129705(0) ack 4113740579 win 5792 <mss 1460,sackOK,timestamp 25903995 4233878,nop,wscale 2>
16:59:30.726578 IP XX.YY.250.3.32948 > XX.YY.1.73.5001: . ack 1 win 1460 <nop,nop,timestamp 4233879 25903995>
16:59:30.726604 IP XX.YY.250.3.32948 > XX.YY.1.73.5001: P 1:25(24) ack 1 win 1460 <nop,nop,timestamp 4233879 25903995>
16:59:30.726641 IP XX.YY.1.73.5001 > XX.YY.250.3.32948: . ack 25 win 1448 <nop,nop,timestamp 25903995 4233879>
