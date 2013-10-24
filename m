From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: Bluetooth 6LoWPAN and routing
Date: Thu, 24 Oct 2013 09:45:40 +0300
Message-ID: <5268C214.2040307@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:62281 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753177Ab3JXGpt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Oct 2013 02:45:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have been prototyping with BT 6LoWPAN support (using this draft 
http://tools.ietf.org/html/draft-ietf-6lowpan-btle-12 as a reference). I 
sent first version yesterday to linux-bluetooth ml 
http://thread.gmane.org/gmane.linux.bluez.kernel/39394

In this current prototype, after the BT connection is created, the code 
set ups the virtual network interface, sets the IPv6 LL address for it 
and creates an IPv6 route to peer (the BT 6LoWPAN connections are 
point-to-point connections). I am using ip6_route_add() function from 
net/ipv6/route.c file to do that. Unfortunately that function is not 
exported so I GPL exported it for this prototype. Will this kind of 
export accepted in upstream or should I figure out some other way to 
create the desired route?


-- 
Cheers,
Jukka
