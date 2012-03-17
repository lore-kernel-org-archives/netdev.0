From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: linux-3.0.18+r8169+ipv4/tcp forwarding = tso/gso weirdness and performance degration
Date: Sat, 17 Mar 2012 23:20:04 +0100
Message-ID: <20120317222004.GA25455@electric-eye.fr.zoreil.com>
References: <20120314215142.655ae607@vostro> <1331755965.6022.55.camel@edumazet-glaptop> <20120314223343.23dc9df3@vostro> <20120314205319.GA28394@electric-eye.fr.zoreil.com> <20120315080635.1f76512b@vostro> <20120315171148.0050714d@vostro> <20120315191118.GA19809@electric-eye.fr.zoreil.com> <20120316221557.235f5ffd@vostro> <20120317115625.3fc04de4@vostro> <20120317113501.GC20532@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57320 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932487Ab2CQWVz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Mar 2012 18:21:55 -0400
Content-Disposition: inline
In-Reply-To: <20120317113501.GC20532@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> :
[...]
> > Or as easy alternative, enabling the VPD bit in Config1 should allow me
> > to read the EEPROM contents using the PCI /sys/.../vpd interface, right?
> 
> In theory, yes. I have not tested it. Imho both access methods will be
> useful.

I tried vpd and got the eeprom content, duplicated 256 times.

The eeprom content is fairly boring:

# ethtool -e 8169sc-1                                                                      
Offset          Values
------          ------
0x0000          29 81 ec 10 67 81 ec 10 67 81 20 40 01 a1 00 e0 
0x0010          4c 67 00 01 15 cd c2 f7 ff 80 ff ff ff ff ff 13 
0x0020          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0030          ff ff fa d6 ff ff ff ff ff ff ff ff ff ff ff 20 
0x0040          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0050          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0060          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0070          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 

-- 
Ueimor
