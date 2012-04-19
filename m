From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 1/4 (V3)] net: ethtool: add the EEE support
Date: Thu, 19 Apr 2012 16:14:41 +0100
Message-ID: <1334848481.2426.62.camel@bwh-desktop.uk.solarflarecom.com>
References: <1333704559-11251-1-git-send-email-peppe.cavallaro@st.com>
	 <1333704559-11251-2-git-send-email-peppe.cavallaro@st.com>
	 <1334269598.2497.50.camel@bwh-desktop.uk.solarflarecom.com>
	 <4F8BB103.7020107@st.com> <4F900C08.5000906@st.com>
	 <4F9017C6.8070400@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"rayagond@vayavyalabs.com" <rayagond@vayavyalabs.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:37280 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751375Ab2DSPOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 11:14:46 -0400
In-Reply-To: <4F9017C6.8070400@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-19 at 16:48 +0300, Yuval Mintz wrote:
> Hi Peppe,
> 
> > The "set" will be useful for some eth devices (like the stmmac) that can
> > stop/enable internally the eee capability (at mac level).
> 
> If you're already implementing this interface, don't you think it might be
> prudent to create an implementation that can do more than enable/disable
> the interface?
[...]

It's not necessary for anyone to *implement* all of this now, but the
interface should certainly cover any settings that users may reasonably
want to read and configure.  As with most ethtool 'set' operations, any
implementation (driver) can disallow changing any or all settings
(-EOPNOTSUPP or -EINVAL) if it's difficult or impossible to implement
them.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
