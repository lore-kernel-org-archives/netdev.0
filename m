From: Molaei <zohrehmolaei@gmail.com>
Subject: Problem with vlan bridge
Date: Thu, 30 May 2013 06:40:41 +0000 (UTC)
Message-ID: <loom.20130530T080452-121@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:50615 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967616Ab3E3GpF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 May 2013 02:45:05 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Uhwbf-0000ad-SV
	for netdev@vger.kernel.org; Thu, 30 May 2013 08:45:03 +0200
Received: from 89.165.114.144 ([89.165.114.144])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 08:45:03 +0200
Received: from zohrehmolaei by 89.165.114.144 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 08:45:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i have fedora 19 with kernel 3.9 and want to use iproute for adding vlan
bridge. i do this configuration but vlan bridge not work.

ip link add dev br type bridge
ip link set dev br up
ip link add link eth0 name eth0.20 type vlan id 20
ip link set dev eth0.20 up
ip link add link eth1 name eth1.30 type vlan id 30
ip link set dev eth1.30 up

bridge vlan add dev eth0.20 vid 20 
bridge vlan add dev eth1.30 vid 30 

when i sen broadcast message from systemtha connected to eth0, systam
connected to eth1 get broadcast message with vid 200.

please help me
thanks
