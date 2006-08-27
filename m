From: Darren Salt <linux@youmustbejoking.demon.co.uk>
Subject: Re: RTL8136
Date: Mon, 28 Aug 2006 00:00:08 +0100
Message-ID: <4E5D2F7732%linux@youmustbejoking.demon.co.uk>
References: <4E5C083B8E%linux@youmustbejoking.demon.co.uk> <20060825190455.GA14812@electric-eye.fr.zoreil.com>
 <4E5C6C7764%linux@youmustbejoking.demon.co.uk> <4E5CF8AF74%linux@youmustbejoking.demon.co.uk> <20060827214135.GA21464@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchor-post-31.mail.demon.net ([194.217.242.89]:776 "EHLO
	anchor-post-31.mail.demon.net") by vger.kernel.org with ESMTP
	id S1750776AbWH0XV3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Aug 2006 19:21:29 -0400
To: romieu@fr.zoreil.com
In-Reply-To: <20060827214135.GA21464@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I demand that Francois Romieu may or may not have written...

> Darren Salt <linux@youmustbejoking.demon.co.uk> :
> [...]
>> Whoops. I'd not noticed the -rc4 patches...

>> These seem to help a little: mii-tool can reset it and bring the link up
>> regardless of RTL_CFG_{1,2}. After that, RTL_CFG_1 allows sending to work,
>> and RTL_CFG_2 allows both sending and receiving to work (tested by trying
>> to get an IP address via DHCP).

> Did you need to play with mii-tool to have DHCP working or did it work
> automagically (assuming the -rc4 patches + the RTL_CFG_2 change of course)?

The former. Without that, the connection is persistently re-negotiated
(though, according to the switch's LEDs, it's fine before the module is
loaded).

-- 
| Darren Salt    | linux or ds at              | nr. Ashington, | Toon
| RISC OS, Linux | youmustbejoking,demon,co,uk | Northumberland | Army
|   Say NO to UK ID cards. http://www.no2id.net/

Experience is something you don't get until just after you need it.
