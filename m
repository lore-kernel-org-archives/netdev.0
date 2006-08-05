From: Alan Shieh <ashieh@cs.cornell.edu>
Subject: Packet reordering in pcap capture file
Date: Sat, 05 Aug 2006 03:28:38 -0400
Message-ID: <44D448A6.6020803@cs.cornell.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchfe1.cs.cornell.edu ([128.84.97.27]:55853 "EHLO
	exchfe1.cs.cornell.edu") by vger.kernel.org with ESMTP
	id S1422678AbWHEH0f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 03:26:35 -0400
To: linux-net@vger.kernel.org, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi everyone,

I sometimes see packets stored out of order in pcap files that generated 
by "tcpdump -i any" on kernel 2.4.26 with all packets arriving and 
departing on an e1000 NIC. That is, the ordering by receive timestamp on 
the packets is not the same as the ordering of the packets within the file.

In my precise scenario, packets of RX packets show up in the log 230 ms 
later than they ought to based on the receive timestamp. The kernel 
behavior (e.g., the packets that are sent by this node) seems to reflect 
the arrival of the Rx packet at the position in the logfile, rather than 
the arrival time according to the timestamp.

What are some of the known causes of this behavior? I'd like to know 
what locks, etc. might be causing this processing / capture delay.
--
Alan Shieh
PhD Student, Computer Science
331 Upson Hall
Ithaca, NY 14853
