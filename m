From: Jiri Pirko <jiri@resnulli.us>
Subject: Universal tap device
Date: Sat, 16 Feb 2013 15:01:32 +0100
Message-ID: <20130216140132.GB1536@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: arnd@arndb.de, ebiederm@xmission.com, stephen@networkplumber.org,
	eric.dumazet@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:47765 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753204Ab3BPOBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 09:01:37 -0500
Received: by mail-ee0-f48.google.com with SMTP id t10so2218462eei.7
        for <netdev@vger.kernel.org>; Sat, 16 Feb 2013 06:01:36 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all.                                                                  
                                                                         
Looking at macvtap and thinking about the tap solutions in general, I    
think it would be handly to have some universal tap device.              
                                                                         
This could use rx_handler to hook onto any netdev and provide chardev    
tap-like iface to it. Using that, one can just hook onto macvlan device  
and macvtap would not be needed.                                         
                                                                         
This would allow other scenarios like vxlan-tap, vlan-tap, bond-tap or   
whatever.                                                                
                                                                         
Does this idea seem to be reasonable?                                    
                                                                         
Thanks                                                                   
                                                                         
Jiri
