From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: r8169: instant crash if receiving packet larger than MTU
Date: Tue, 17 Feb 2009 23:55:19 +0300
Message-ID: <499B2437.90400@msgid.tls.msk.ru>
References: <4996E054.20905@msgid.tls.msk.ru> <20090217193749.GA12921@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([81.13.33.159]:57163 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751706AbZBQU4r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Feb 2009 15:56:47 -0500
In-Reply-To: <20090217193749.GA12921@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> Michael Tokarev <mjt@tls.msk.ru> :
>> I played with jumbo frames today at home on two
>> machines with built-in r8169 NICs.  And discovered
>> that, after enabling larger packets on one machine,
>> it's sufficient to send SINGLE packet to immediately,
>> instantly crash the other machine.
> 
> Which size did you use and how did it crash (dead keyboard leds
> without any message in the console ?) ?

Original interface MTU was unchanged from the default 1500 bytes.
The packet I sent was of size 8000 bytes.

The crash - one of the machines in question was completely dead,
nothing on the console, and dead keyboard leds.  Another with the
same chip rebooted instantly.

/mjt

