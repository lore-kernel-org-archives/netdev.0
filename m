From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 2.6.9-rc1-bk11+ and 2.6.9-rc1-mm3,4 r8169: freeze during boot (FIX included)
Date: Thu, 16 Sep 2004 09:02:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916070211.GA32592@electric-eye.fr.zoreil.com>
References: <200409130035.50823.hfvogt@arcor.de> <200409160040.03532.hfvogt@arcor.de> <20040915230936.GA24467@electric-eye.fr.zoreil.com> <200409160132.34160.hfvogt@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jon Mason <jdmason@us.ibm.com>, linux-kernel@vger.kernel.org,
        jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Hans-Frieder Vogt <hfvogt@arcor.de>
Content-Disposition: inline
In-Reply-To: <200409160132.34160.hfvogt@arcor.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hans-Frieder Vogt <hfvogt@arcor.de> :
[...]
> r8169: eth0: Config2 = 0x10
> 
> ... does not seem to be the already known issue? Anyhow, if you have more 

Typo of mine: it is. The BSD people have noticed some time ago that the DAC
of the chipset apparently does bad things when the card is inserted in a
32 bits wide slot. 

Jon, if your ppc64 box offers 64 bits wide PCI slots, it would be nice if
you could ttry 2.6.9-rc2-bkX, apply
http://www.fr.zoreil.com/people/francois/misc/r8169-xx0.patch
and report the content of the "Config2" line in the logs of the kernel.

--
Ueimor
