From: "Thomas A. Oehser" <tom@toms.net>
Subject: Re: r8169 locks up in 2.6.16.5
Date: Sun, 16 Apr 2006 09:42:01 -0400
Message-ID: <20060416134201.GA2681@jupiter.toms.net>
References: <20060415204716.GA1755@jupiter.toms.net> <20060416005821.GA9821@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter.toms.net ([207.145.105.50]:54983 "EHLO jupiter.toms.net")
	by vger.kernel.org with ESMTP id S1750728AbWDPNmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Apr 2006 09:42:10 -0400
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060416005821.GA9821@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Which motherboard and filesystem do you use ?

It's an MSI using EXT3.

> Can you send before and after the ping takes 9000 ms:
> - ifconfig output
> - registers dump via ethtool 
> 
> 9000ms seems quite close to the watchdog timeout (6 s) + ping
> interval. Complete dmesg and .config will be welcome.

I tested with everything turned off (no SMP, no swap, no
USB, no firewire, no iptables, no lmsensors, flat 1G memory,
etc. etc. etc.) except the bare minimum (LSI new Megaraid for the
SCSI and SATA raid arrays, both of which use the same driver, EXT3,
VGA console, keyboard, mouse).  Also, with everything static and
no modules.

Changing _nothing_ other than replacing EEPRO100 with R8169 and
vice versa causes it to work perfectly or fail abominably... the
machine always had both nics physically connected, so it was just
the software change of one driver or the other as eth0.

There was no dmesg output.

Note, one thing I have noticed- it always failed when the load was
coming from the same machine.  Perhaps the packets from that machine
have something about them that particularly spasms the driver?
I'll look at what nic and driver that machine is using.

Note, it will be a day or few before I can retest with ethtool etc.,
I have to do my taxes today.

-Thanks, -Tom

