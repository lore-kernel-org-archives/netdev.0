From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Wed, 18 Nov 2015 00:21:08 +0100
Message-ID: <20151117232108.GC3362@electric-eye.fr.zoreil.com>
References: <20130309064647.GC4984@marvin.atrad.com.au>
 <20130311000216.GA31808@zoreil.com>
 <20130405001526.GC19253@marvin.atrad.com.au>
 <20151117015605.GI22941@marvin.atrad.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jonathan Woithe <jwoithe@atrad.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52012 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754026AbbKQXVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 18:21:17 -0500
Content-Disposition: inline
In-Reply-To: <20151117015605.GI22941@marvin.atrad.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jonathan Woithe <jwoithe@atrad.com.au> :
[...]
> It would be advantageous if we could upgrade this Linux system to a kernel
> more recent than 2.6.35.11, but that will require a resolution to this
> problem.  Since 2.6.35.11 works while current kernels do not, the only other
> option is to stick with 2.6.35.11.  Is there anything we can do to try to
> track down the problem?  I'm willing and able to run further tests on the
> system as required.

If you were tracking the hardware stats (ethtool -S), would you be able to
tell if the hardware sees the relevant UDP packets long before the driver
does ?

Would you be able to ascertain that the interrupt mask register (ethtool -d)
is not set for an excessive amount of time ?

-- 
Ueimor
