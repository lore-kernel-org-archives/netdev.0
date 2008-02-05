From: Van Petron <pravo@hnet.ru>
Subject: etcnet Wi-Fi tuning
Date: Tue, 05 Feb 2008 08:32:12 +0600
Message-ID: <fo8hrq$g81$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:37925 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751818AbYBEOPE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2008 09:15:04 -0500
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1JMOZi-00008L-Np
	for netdev@vger.kernel.org; Tue, 05 Feb 2008 14:15:02 +0000
Received: from gw.nsib.ru ([217.117.80.2])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 05 Feb 2008 14:15:02 +0000
Received: from pravo by gw.nsib.ru with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 05 Feb 2008 14:15:02 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
Can you help me? What can I read to solve the task:
The is Altlinux installed on the computer with Ethernet card connected 
with the local network/Internet (DHCP) + WiFi USB stick.
There is notebook with Windows XP + Wi-FI PCMCIA card.
I want to connect with notebook AD-HOC: Samba, printer (on my PC 
(CUPS)). I also want to retransmit local network/Internet to the notebook.
Altlinux has etcnet.
I made some tuning in ifaces/wlan0, but notebook cannot connect
with wi-fi net "Ivp" (there are two, and it cannot connect with each of 
then).
Folder wlan0:
ipv4address:
192.168.0.2/24

ipv4route:
default via 192.168.0.1

iwconfig:
essid Ivp
mode 1
ap 00-50-22-E2-B6-OF
channel 3
rate 54M

options:
TYPE=eth
MODULE=ndiswrapper
NEVER_RMMOD=YES
USE_HOTPLUG=no
ONBOOT=yes

wpa_supplicant.conf:
ctrl_interface=/var/run/wpa_supplicant
update_config=1

network={
          ssid="Ivp"
          bssid=00-15-E9-B3-2A-20
          key_mgmt=NONE
}


What is wrong?

I.P.

