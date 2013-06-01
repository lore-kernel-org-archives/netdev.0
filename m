From: kermani <somayeh.kermani@gmail.com>
Subject: Re: Problem with vlan bridge
Date: Sat, 1 Jun 2013 07:02:29 +0000 (UTC)
Message-ID: <loom.20130601T085324-570@post.gmane.org>
References: <loom.20130530T080452-121@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:48415 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755880Ab3FAHFH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Jun 2013 03:05:07 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Uifs7-0002a0-TA
	for netdev@vger.kernel.org; Sat, 01 Jun 2013 09:05:03 +0200
Received: from 89.165.114.144 ([89.165.114.144])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 01 Jun 2013 09:05:03 +0200
Received: from somayeh.kermani by 89.165.114.144 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 01 Jun 2013 09:05:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Molaei <zohrehmolaei <at> gmail.com> writes:

> 
> i have fedora 19 with kernel 3.9 and want to use iproute for adding vlan
> bridge. i do this configuration but vlan bridge not work.
> 
> ip link add dev br type bridge
> ip link set dev br up
> ip link add link eth0 name eth0.20 type vlan id 20
> ip link set dev eth0.20 up
> ip link add link eth1 name eth1.30 type vlan id 30
> ip link set dev eth1.30 up
> 
> bridge vlan add dev eth0.20 vid 20 
> bridge vlan add dev eth1.30 vid 30 
> 
> when i sen broadcast message from systemtha connected to eth0, systam
> connected to eth1 get broadcast message with vid 200.
> 
> please help me
> thanks
> 
> 

I have same problem and configuration is as a follow:

ip link add dev br type bridge
ip link set dev br up
ip link add link eth0 name eth0.20 type vlan id 20
ip link set dev eth0.20 up
ip link add link eth1 name eth1.30 type vlan id 30
ip link set dev eth1.30 up

ip link set eth0.20 master br
ip link set eth1.30 master br

bridge vlan add dev eth0.20 vid 20 
bridge vlan add dev eth1.30 vid 30 

I can't find any document or example to perform that. 
I appreciate your reply.
Regards
