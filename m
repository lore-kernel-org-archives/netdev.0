From: Andrew Morton <akpm@linux-foundation.org>
Subject: borkage in 2.6.23-rc4-mm1
Date: Fri, 31 Aug 2007 21:16:03 -0700
Message-ID: <20070831211603.083dfed2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46412 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750823AbXIAEP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 00:15:59 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Am seeing random crap like this:

Aug 31 20:57:46 sony dhclient: DHCPREQUEST on eth1 to 255.255.255.255 port 67
Aug 31 20:57:51 sony dhclient: DHCPREQUEST on eth1 to 255.255.255.255 port 67
Aug 31 20:57:56 sony dhclient: dhclient(4537) is already running - exiting. 
Aug 31 20:57:56 sony dhclient: exiting.
Aug 31 20:58:05 sony dhclient: DHCPDISCOVER on eth1 to 255.255.255.255 port 67 interval 4
Aug 31 20:58:07 sony kernel: ipw2200: Firmware error detected.  Restarting.
Aug 31 20:58:09 sony dhclient: DHCPDISCOVER on eth1 to 255.255.255.255 port 67 interval 7
Aug 31 20:58:16 sony dhclient: DHCPDISCOVER on eth1 to 255.255.255.255 port 67 interval 14
Aug 31 20:58:16 sony dhclient: DHCPOFFER from 192.168.2.1
Aug 31 20:58:16 sony dhclient: DHCPREQUEST on eth1 to 255.255.255.255 port 67
Aug 31 20:58:20 sony dhclient: DHCPREQUEST on eth1 to 255.255.255.255 port 67
Aug 31 20:58:20 sony dhclient: DHCPACK from 192.168.2.1
Aug 31 20:58:20 sony NET[4946]: /sbin/dhclient-script : updated /etc/resolv.conf
Aug 31 20:58:20 sony dhclient: bound to 192.168.2.5 -- renewal in 125513 seconds.
Aug 31 20:59:45 sony ntpd[2059]: sendto(192.36.143.234): Invalid argument
Aug 31 20:59:51 sony ntpd[2059]: sendto(193.225.14.163): Invalid argument
Aug 31 20:59:52 sony ntpd[2059]: sendto(193.60.199.78): Invalid argument
Aug 31 21:01:31 sony kernel: ipw2200: Firmware error detected.  Restarting.
Aug 31 21:01:54 sony ntpd[2059]: sendto(192.36.143.234): Invalid argument
Aug 31 21:01:59 sony ntpd[2059]: sendto(193.225.14.163): Invalid argument
Aug 31 21:02:02 sony ntpd[2059]: sendto(193.60.199.78): Invalid argument
Aug 31 21:04:04 sony ntpd[2059]: sendto(192.36.143.234): Invalid argument
Aug 31 21:04:05 sony kernel: ipw2200: Firmware error detected.  Restarting.
Aug 31 21:04:07 sony ntpd[2059]: sendto(193.225.14.163): Invalid argument
Aug 31 21:04:12 sony ntpd[2059]: sendto(193.60.199.78): Invalid argument
Aug 31 21:05:21 sony kernel: ipw2200: Firmware error detected.  Restarting.

when trying to use ssh on the current rc4-mm1 lineup.
