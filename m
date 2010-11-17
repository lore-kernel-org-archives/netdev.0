From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.37-rc1] net-next: Add multiqueue support to vmxnet3
 driver v3
Date: Wed, 17 Nov 2010 09:27:22 -0800 (PST)
Message-ID: <20101117.092722.193716325.davem@davemloft.net>
References: <alpine.LRH.2.00.1011101426410.816@sbhatewara-dev1.eng.vmware.com>
	<alpine.LRH.2.00.1011161939500.25227@sbhatewara-dev1.eng.vmware.com>
	<1290014618.2588.50.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbhatewara@vmware.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, pv-drivers@vmware.com,
	linux-kernel@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51280
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754518Ab0KQR05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 12:26:57 -0500
In-Reply-To: <1290014618.2588.50.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 17 Nov 2010 17:23:38 +0000

> On Tue, 2010-11-16 at 21:14 -0800, Shreyas Bhatewara wrote:
> [...]
>> Okay. I am resending the patch with no module params what-so-ever. The default
>> is no-multiqueue though. Single queue code has matured and is optimized for
>> performance. Multiqueue code has got relatively lesser performance tuning. Since
>> there is no way to switch between the two modes as of now, it only makes sense
>> to keep the best known as default. When configuration knobs are introduced 
>> later, multiqueue can be made default.
> 
> But so far as I can see there is currently *no* way to enable multiqueue
> without editing the code.  Perhaps there could be an experimental config
> option that people can use to enable and test it now, before we sort out
> the proper API?

It should be turned on by default, otherwise don't add the code until
it's "ready."

We had slight performance regressions in the past when various drivers
added multiqueue support, but the aggregate performance increased for
multi-flow cases, and this was deemed a fine tradeoff.  I was hoping
you'd use similar logic.

Otherwise, send this stuff when it's ready, and no sooner.
