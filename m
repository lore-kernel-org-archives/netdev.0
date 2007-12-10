From: "Chris Friesen" <cfriesen@nortel.com>
Subject: "ip neigh show" not showing arp cache entries?
Date: Mon, 10 Dec 2007 11:36:01 -0600
Message-ID: <475D7901.1040900@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04e.nortel.com ([47.129.242.56]:40083 "EHLO
	zcars04e.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533AbXLJRgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 12:36:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm seeing some strange behaviour on a 2.6.14 ppc64 system.  If I run 
"ip neigh show" it prints out nothing, but if I run "arp" then I see the 
other nodes on the local network.


root@base0-0-0-5-0-11-1:/root> ip neigh show
root@base0-0-0-5-0-11-1:/root> arp -n
Address                  HWtype  HWaddress           Flags Mask 
    Iface
172.24.132.0             ether   00:01:AF:14:E8:DA   C 
    bond0
172.24.132.1                     (incomplete) 
    bond0
172.24.136.0             ether   00:C0:8B:07:B3:7E   C 
    bond0
172.24.132.4             ether   00:01:AF:14:E8:DA   C 
    bond0
172.24.132.2             ether   00:01:AF:14:E8:DA   C 
    bond0


Any ideas what's going on here?

Thanks,

Chris
