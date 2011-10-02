From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Why might packets go into a tunnel and not come out
Date: Sun, 02 Oct 2011 11:25:04 +0200
Message-ID: <4E882DF0.90404@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay007.isp.belgacom.be ([195.238.6.173]:62104 "EHLO
	mailrelay007.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751456Ab1JBJ2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Oct 2011 05:28:18 -0400
Received: from [192.168.1.6] (wendy.xperim.be [192.168.1.6])
	by zotac.xperim.be (8.14.3/8.14.3/Debian-9.2ubuntu1) with ESMTP id p929P4hg000695
	for <netdev@vger.kernel.org>; Sun, 2 Oct 2011 11:25:07 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All,

This is a question that I would have posted to linux-net had it still 
existed. I beg your indulgence.

I have established an SSH tunnel (device tunX) between two remote hosts. 
This tunnel is operating properly in that I can ping each peer from the 
other.

I am now trying to route traffic through this tunnel to onward 
destinations. This is not working: when I ping such an onward 
destination I can see the packets going into the tunnel (using tcpdump) 
but they're not coming out of the other end (again as seen by tcpdump).

I have added logging to all firewall rules that drop or reject traffic; 
nothing is logged. (And yes I have checked that logging itself works by 
briefly adding logging to an ACCEPT rule). Routing is enabled on both 
hosts. The counters for the tun devices (as seen using ifconfig) do not 
show any dropped traffic.

I am not asking you to debug my problem for me, but could anyone please 
point me to an overview of the reasons why packets might be going into 
one end of a tunnel and not come out the other end? I have studied the 
diagram at the following link and I think I've checked the potential 
issues that it prompts:

http://www.shorewall.net/Shorewall_and_Routing.html

Many thanks.

Jan
