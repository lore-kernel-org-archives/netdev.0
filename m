From: <arun.prabha@wipro.com>
Subject: Ethernet bridge and PF_PACKET sockets
Date: Wed, 13 Apr 2005 17:29:26 +0530
Message-ID: <3D81D46E0E63304FBC9ECEB136B4CF2610A1E8@BLR-EC-MBX04.wipro.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I am using a PF_PACKET socket to capture packets of a particular type,
say ETH_P_X (where ETH_P_X is not ETH_P_ALL) from the ethernet
interface, eth0. Everything will work fine. But when I configure a
bridge br0, I feel that I will stop receiving the packets (since
skb->dev is changed in br_pass_frame_up()).

1. Is my reasoning incorrect?
2. Is this the expected behavior?
3. What can I do to get the packets, bind to br0??
4. Assuming bridge may/may not be always  configured and I want to get
   packets from the ethernet interface (without really bothering about
   the bridge), what is the best way to do it?

I should be able to transmit packets on the ethernet via the PF_PACKET
socket.

Thanks in advance,
Arun.
