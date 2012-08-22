From: Chris Friesen <chris.friesen@genband.com>
Subject: TIPC handling of ethernet mac address change
Date: Wed, 22 Aug 2012 09:36:40 -0600
Message-ID: <5034FC88.8030403@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Allan Stephens <allan.stephens@windriver.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og105.obsmtp.com ([64.18.2.163]:45570 "EHLO
	exprod7og105.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752439Ab2HVPgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 11:36:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm pretty new to tipc so pardon me if I use the wrong terminology. :)

I'm using TIPC 1.7.7 and bonding.  I'm seeing some strange behaviour 
when the bond MAC address changes--the tipc LINK_CONFIG messages still 
contain the old MAC address embedded in them.  This causes the other end 
to send back to us on the wrong MAC and the packets get dropped.

I see recv_notification() has a case for NETDEV_CHANGEADDR so it looks 
like MAC address change was intended to be handled, but I'm not entirely 
clear on where the MAC address is supposed to be changed.

Any assistance on debugging/patching this would be appreciated.

Chris


-- 

Chris Friesen
Software Designer

3500 Carling Avenue
Ottawa, Ontario K2H 8E9
www.genband.com
