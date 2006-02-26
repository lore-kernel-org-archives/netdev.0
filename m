From: John Zielinski <john_ml@undead.cc>
Subject: RTL 8139 stops RX after receiving a jumbo frame
Date: Sat, 25 Feb 2006 23:23:47 -0500
Message-ID: <44012D53.30700@undead.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751201AbWBZEXw@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I was testing a patch for the VIA Velocity adapter and accidentally 
pinged a jumbo packet to 192.168.0.1 instead of 192.168.0.10.  The 
machine I pinged is my Linux firewall box with a RTL 8139 card (8139 rev 
K chip).  When my internet connection went down I tried pinging the 
firewall with regular sized packets and it wouldn't respond.  I had to 
ifdown/ifup the interface to get things going again.  The output from 
ifconfig shows I had an overrun.

I'm replacing that card with a VIA Velocity card as I'm upgrading my 
entire network to GigE but a friend of mine is only doing a partial 
upgrade and will have several boxes with RTL 8139's still in them.  I'm 
going to move the RTL card into my test box for further testing.

I'm surprised that the switch actually let the jumbo packet through onto 
a 100Mbit link.  I'm going to see if I can find a non RTL 8139 card in 
my parts bin and see what that one does.

What's the normal behavior for overruns on an interface?
