From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 1/4] phy: add the EEE support and the way to access
 to the MMD regs
Date: Thu, 8 Mar 2012 18:29:33 +0000
Message-ID: <1331231373.2481.7.camel@bwh-desktop>
References: <4F4E4D4B.3040909@st.com>
	  <1331022494-12891-1-git-send-email-peppe.cavallaro@st.com>
	  <1331022494-12891-2-git-send-email-peppe.cavallaro@st.com>
	  <1331052913.2333.16.camel@bwh-desktop>
	 <1331053557.2333.19.camel@bwh-desktop> <4F58C821.3040104@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<rayagond@vayavyalabs.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:38387 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754391Ab2CHS3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 13:29:42 -0500
In-Reply-To: <4F58C821.3040104@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-03-08 at 15:54 +0100, Giuseppe CAVALLARO wrote:
> Hello Ben
> 
> thanks for your review and sorry for my delay.
> 
> On 3/6/2012 6:05 PM, Ben Hutchings wrote:
[...]
> >>> +static inline void mmd_phy_cl45(struct mii_bus *bus, int prtad, int devad,
> >>> +				int addr)
> >> [...]
> >>> +/**
> >>> + * read_phy_mmd - reads data from the MMC register (clause 22 to access to
> >>> + * clause 45)
> >> [...]
> >>> +/**
> >>> + * write_phy_mmd - writes data to the MMC register (clause 22 to access to
> >>> + * clause 45)
> >>
> >> These names need to be changed as phylib also supports (or is intended
> >> to support) real clause 45 PHYs.
> 
> 
> What do you suggest? Do I have to rename these functions for example as?
> 
> write_phy_mmd  ---->    phy_write_mmd_cl45
> read_phy_mmd   ---->    phy_read_mmd_cl45

These are a means to access MMDs through the clause 22 MDIO protocol, so
it seems to me that the name should include '22' and not '45'.  But
perhaps it would be more obvious to use the word 'indirect'.

> I've also another doubt. I put this code in phy_device.c. Is it correct?
> 
> Maybe, it could be better have it in phy.c? What do you think?
[...]

No idea, I don't have any involvement in phylib.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
