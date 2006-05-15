From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: ipv6 routing broken in 2.6.17-rc3,4
Date: Mon, 15 May 2006 19:05:39 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0605151904110.12081@netcore.fi>
References: <Pine.SOC.4.61.0605150909510.29527@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:61141 "EHLO netcore.fi")
	by vger.kernel.org with ESMTP id S1751596AbWEOQFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 12:05:41 -0400
To: Meelis Roos <mroos@linux.ee>
In-Reply-To: <Pine.SOC.4.61.0605150909510.29527@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 May 2006, Meelis Roos wrote:
> On my home 6to4 gw, ipv6 routing seems to be broken and everything is sent to 
> 6to4 tunnel (the default route). It worked with fine for a long time and with 
> 2.6.17-rc2-g4d5c34ec and it's broken with vmlinuz-2.6.17-rc3-g3cd73eed and 
> 2.6.17-rc4-g9be2f7c3 (yesterdays kernel).
...
> vaarikas:~# ip -6 route
> 2002:5283:297e::/48 dev tun6to4  metric 256  expires 21332659sec mtu 1480 
> advmss 1420 hoplimit 4294967295

You're using the wrong prefix length.  The right one is /16.  Does 
that work?

Maybe the 6to4 hack which didn't heed routing table (so either prefix 
length was OK) was removed or changed...

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
