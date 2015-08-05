From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] sky2: Add module parameter for passing the MAC address
Date: Wed, 5 Aug 2015 22:33:42 +0200
Message-ID: <20150805203342.GA26748@electric-eye.fr.zoreil.com>
References: <1438789854-29194-1-git-send-email-Liviu.Dudau@arm.com>
 <20150805094057.59260077@urahara>
 <20150805171652.GG20890@e106497-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Mirko Lindner <mlindner@marvell.com>,
	"ryan.harkin@linaro.org" <ryan.harkin@linaro.org>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
To: Liviu Dudau <Liviu.Dudau@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43740 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026AbbHEUeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 16:34:07 -0400
Content-Disposition: inline
In-Reply-To: <20150805171652.GG20890@e106497-lin.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Liviu Dudau <Liviu.Dudau@arm.com> :
> On Wed, Aug 05, 2015 at 05:40:57PM +0100, Stephen Hemminger wrote:
[...]
> > Yes, I can see that this can be a real problem, and other drivers
> > solve the problem. The standard method is to assign a random mac address
> > (and then let scripts overwrite) rather than introducing module parameter.
> > Module parameters are discouraged because they are device specific.
> > 
> 
> I agree. However, in my case, the boards people have assigned MAC addresses
> to the chip, they just didn't built the board in such a way as to allow one
> to store that MAC address in a permanent way :( And no, I can't use the DT
> because the chip is actually on the PCIe bus.
> 
> Even with the generation of a random address, it still needs to be copied
> into the device, so I would guess that a version of the patch I've sent is
> still relevant?

Assuming a random address is generated, could you elaborate what is needed
that sky2_set_mac_address fails to provide ?

-- 
Ueimor
