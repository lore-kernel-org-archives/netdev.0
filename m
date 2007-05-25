From: Nicklas Bondesson <nicklas.bondesson@pakompetens.se>
Subject: Mixing tagged and untagged vlans using via-velocity driver
Date: Fri, 25 May 2007 11:04:36 +0200
Message-ID: <4656A6A4.1030305@pakompetens.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.safenet.se ([84.243.19.88]:36665 "HELO mail.safenet.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751491AbXEYJLU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 May 2007 05:11:20 -0400
Received: from unknown ([127.10.10.10])
	by localhost (app04.be.safenet.se [127.10.10.10]) (amavisd-new, port 10628)
	id SMUyu3v6-f7Y for <netdev@vger.kernel.org>;
	Fri, 25 May 2007 11:04:39 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am trying to setup two vlans (one tagged and one untagged) using the 
native via-velocity driver in kernel 2.6.21.1 on a single nic.

I can set it up tagged or untagged without any problems, but not both at 
the same time. Is this even possible with this driver?

To enable vlan5 tagging on the nic I have tried the following:

alias eth1 via_velocity
options eth1 enable_tagging=1 VID_setting=5

At this point I can communicate with vlan5. When I try to bring up a 
virtual interface using vconfig it seems to inherit the vlan5 tagging, 
thus making it impossible to communicate with an untagged vlan.

I have also tried the other way arround. If I skip "enable_tagging=1 
VID_setting=5", I can communicate with a non tagged vlan. If I bring up 
a new virtual interface (tagged vlan5) using vconfig it does not work.

I'm stuck. If anyone could shed some light on this it would be greatly 
appreciated.

Nicklas

