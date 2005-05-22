From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Good (exemplary) network driver?
Date: Mon, 23 May 2005 00:34:04 +0200
Message-ID: <20050522223404.GA8689@electric-eye.fr.zoreil.com>
References: <4290D309.4020301@otaku42.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Renzmann <netdev@nospam.otaku42.de>
Content-Disposition: inline
In-Reply-To: <4290D309.4020301@otaku42.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Renzmann <netdev@nospam.otaku42.de> :
[...]
> Short question: which network driver is commonly regarded as a good 
> implementation of what a linux network driver should look like? Is there 
> something like a "reference driver" available, which could be consulted 
> for all of those "how should I do xyz" questions?

drivers/net/pci-skeleton.c provides some hints but it is not the best
maintained/cleaned-up/feature-rich driver (no module_parm, no ethtool, no
vlan, etc.). You will find some answers in the gigabit drivers as well.

--
Ueimor
