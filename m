From: Darren Salt <linux@youmustbejoking.demon.co.uk>
Subject: Re: RTL8136
Date: Sat, 26 Aug 2006 12:30:14 +0100
Message-ID: <4E5C6C7764%linux@youmustbejoking.demon.co.uk>
References: <4E5C083B8E%linux@youmustbejoking.demon.co.uk> <20060825190455.GA14812@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchor-post-35.mail.demon.net ([194.217.242.85]:35850 "EHLO
	anchor-post-35.mail.demon.net") by vger.kernel.org with ESMTP
	id S1751584AbWHZNbp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Aug 2006 09:31:45 -0400
To: netdev@vger.kernel.org, romieu@fr.zoreil.com
In-Reply-To: <20060825190455.GA14812@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I demand that Francois Romieu may or may not have written...

> Darren Salt <linux@youmustbejoking.demon.co.uk> :
>> In case you don't yet have an lspci dump for an RTL8136, here's one for a
>> device which is working with the r1000 driver which is supplied with
>> Ubuntu dapper (though the machine in question - a Toshiba Equium A110-233
>> - is actually running Debian testing.)

> Thanks. The MM region was correctly guessed. If the driver does not work,

... which it doesn't - the connection is lost, and the hardware continually
tries and fails to re-establish it. I can at least get a 10baseT/full
connection with help from ethtool, but trying to send anything over it fails;
switching back to r1000 (and forcing the connection speed) gets things
working again, though a reboot seems to be needed to get auto-negotiation of
higher speeds working again (note that it's limited to 100baseT/full; I
have nothing else capable of 1000baseT).

> you can try to s/RTL_CFG_1/RTL_CFG_2/ for the 0x8136 entry in the
> rtl8169_pci_tbl array.

That appears to make no difference.

-- 
| Darren Salt    | linux or ds at              | nr. Ashington, | Toon
| RISC OS, Linux | youmustbejoking,demon,co,uk | Northumberland | Army
|   Kill all extremists!

"The universe is a spheroid region 705m in diameter."
