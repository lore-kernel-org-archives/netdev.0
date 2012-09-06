From: Chris Friesen <chris.friesen@genband.com>
Subject: [RFC] ip autoconfig: allow specifying a list of devices rather than
 one or all
Date: Thu, 06 Sep 2012 16:35:51 -0600
Message-ID: <50492547.8070307@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og117.obsmtp.com ([64.18.2.6]:46332 "EHLO
	exprod7og117.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753788Ab2IFWgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 18:36:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We have an embedded system that boots of the network.  This system has a 
pair of bonded gigE links used for booting and management, and a pair of 
bonded 10G links used for data traffic.

What we're seeing is that when ip_auto_config() calls
ic_open_devs() to open up all the network ports, the data ports 
immediately start getting *hammered* with traffic, we get "nf_conntrack: 
table full, dropping packet", errors, and we sometimes lose the DHCP 
responses because of this.

We need to be able to boot off of both the gigE ports for redundancy, so 
it seems like it might be a reasonable idea to extend the "ip=" boot arg 
to allow specifying a list of devices rather than choosing between a 
single device or all of them.

Thoughts?  Anyone ever done this?

Chris


-- 

Chris Friesen
Software Designer

3500 Carling Avenue
Ottawa, Ontario K2H 8E9
www.genband.com
