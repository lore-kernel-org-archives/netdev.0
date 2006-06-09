From: "Vasantha Kumar Puttappa" <vasanthakumar@iitb.ac.in>
Subject: [Fwd: Packet Lost] ip_rt_bug error
Date: Fri, 9 Jun 2006 13:08:09 +0530 (IST)
Message-ID: <4561.10.12.25.5.1149838689.squirrel@gpo.iitb.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.iitb.ac.in ([202.68.145.249]:46825 "HELO smtp1.iitb.ac.in")
	by vger.kernel.org with SMTP id S965083AbWFIKga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2006 06:36:30 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
  I am working on a small application using iptables/libipq. In this, the
application would capture a specific packets based on the destination IP
address. Then I encapsulate this IP packet inside another new IP packet.

My problem is that the encapsulation part works fine in
kernel-2.6.11-6(mandriva 2005) and IPtables V 1.2.9.
(I can capture encapsulated packets using tcpdump at the sender side i.e,
packets are being put on to the network)


But this doesn't work in kernel-2.6.12-12(mandriva 2006) and the
IPtables-1.3.5(even though there are no erros after callig
ipq_set_verdict, the packets are not being put on to the channel. The
packets are getting lost after
the call to ipq_set_verdict)


/***

In my syslog I can see ip_rt_bug , but isn't ip_rt_bug occurs when
destiantion address is changed to local address ?

In my application I am changing destination IP to an another non-local IP
address.
****/

please let me know if you need more information


As you already have experience with these kinds of error plz help me out here

Thanx






