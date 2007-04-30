From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169.c broke for me from 2.6.20.4 to 2.6.21
Date: Mon, 30 Apr 2007 09:16:59 +0200
Message-ID: <20070430071659.GA22320@electric-eye.fr.zoreil.com>
References: <46357F2B.2070806@foks.8m.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jelle Foks <jelle@foks.8m.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:48528 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423104AbXD3HSB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 03:18:01 -0400
Content-Disposition: inline
In-Reply-To: <46357F2B.2070806@foks.8m.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jelle Foks <jelle@foks.8m.com> :
[...]
> When I upgraded from 2.6.20.4 to 2.6.21, the r8169 kept thinking that
> the link was down, while with 2.6.20.4, the link was detected at 10Mbit/s.
> 
> This is on a (I admit, probably out-of-spec) cable to a Gbit switch from
> the r8169 on the mainboard of an AOpen XC Cube EX761.

Grmblmbl...

> With 2.6.20.4, the 'link' goes through these states when I boot:
> 
> r8169: eth1: link down
> ADDRCONF(NETDEV_UP): link is not ready
> ADDRCONF(NETDEV_CHANGE):  link becomes ready
> r8169: eth1: link up
> 
> And then it works (at 10Mbit). With 2.6.21, the link stays down.
> 
> When I revert rtl8169_xmii_reset_enable() to the code from the driver in
> 2.6.20.4 (see the diff below), then it works again, with the same
> behaviour as with 2.6.20.4.
[snip]

This patch alone is known to change things but it does not work
everywhere :o/

Can you:
- send the output of a 'lspci -vvx'
- send the output of mii-tool including hex dump of the registers with
  2.6.20.4 and 2.6.21
- try 2.6.21 + http://www.fr.zoreil.com/people/francois/misc/20070430-2.6.21-r8169-test.patch

-- 
Ueimor

Anybody got a battery for my Ultra 10 ?
