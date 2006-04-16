From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 locks up in 2.6.16.5
Date: Sun, 16 Apr 2006 02:58:21 +0200
Message-ID: <20060416005821.GA9821@electric-eye.fr.zoreil.com>
References: <20060415204716.GA1755@jupiter.toms.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:63912 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932178AbWDPBBm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Apr 2006 21:01:42 -0400
To: "Thomas A. Oehser" <tom@toms.net>
Content-Disposition: inline
In-Reply-To: <20060415204716.GA1755@jupiter.toms.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas A. Oehser <tom@toms.net> :
[...]
> On a dual Athlon 2600+ MP with 2GB RAM, and nothing else running.
       ^^^^^^^^^^^^      ^^
Which motherboard and filesystem do you use ?

[...]
> Should I just give these cards away and forget I ever heard of RealTeK?

I don't think so.

> Is it known that this driver, or this card, or the combination, is unstable?

Some r8169 PR are still open (mac address change, acpi suspend/resume
and "special" motherboard) but there is no clear pattern related to
stability under load. 

Can you send before and after the ping takes 9000 ms:
- ifconfig output
- registers dump via ethtool 

9000ms seems quite close to the watchdog timeout (6 s) + ping
interval. Complete dmesg and .config will be welcome.

-- 
Ueimor
