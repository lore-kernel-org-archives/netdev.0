From: Darren Salt <linux@youmustbejoking.demon.co.uk>
Subject: Re: RTL8136
Date: Sun, 27 Aug 2006 14:01:48 +0100
Message-ID: <4E5CF8AF74%linux@youmustbejoking.demon.co.uk>
References: <4E5C083B8E%linux@youmustbejoking.demon.co.uk> <20060825190455.GA14812@electric-eye.fr.zoreil.com>
 <4E5C6C7764%linux@youmustbejoking.demon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchor-post-30.mail.demon.net ([194.217.242.88]:34315 "EHLO
	anchor-post-30.mail.demon.net") by vger.kernel.org with ESMTP
	id S932081AbWH0NFq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Aug 2006 09:05:46 -0400
To: netdev@vger.kernel.org, romieu@fr.zoreil.com
In-Reply-To: <4E5C6C7764%linux@youmustbejoking.demon.co.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I demand that I definitely did write...

> I demand that Francois Romieu may or may not have written...
>> Darren Salt <linux@youmustbejoking.demon.co.uk> :
>>> In case you don't yet have an lspci dump for an RTL8136, here's one for a
>>> device which is working with the r1000 driver which is supplied with
>>> Ubuntu dapper (though the machine in question - a Toshiba Equium A110-233
>>> - is actually running Debian testing.)

>> Thanks. The MM region was correctly guessed. If the driver does not work,

> ... which it doesn't - the connection is lost, and the hardware continually
> tries and fails to re-establish it. [...]

Whoops. I'd not noticed the -rc4 patches...

These seem to help a little: mii-tool can reset it and bring the link up
regardless of RTL_CFG_{1,2}. After that, RTL_CFG_1 allows sending to work,
and RTL_CFG_2 allows both sending and receiving to work (tested by trying to
get an IP address via DHCP).

[snip]
-- 
| Darren Salt    | linux or ds at              | nr. Ashington, | Toon
| RISC OS, Linux | youmustbejoking,demon,co,uk | Northumberland | Army
| + Output *more* particulate pollutants.      BUFFER AGAINST GLOBAL WARMING.

"It'll drive the conspiracy nuts crazy, but WTH."
