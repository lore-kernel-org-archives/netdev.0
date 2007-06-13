From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 13 Jun 2007 08:32:15 -0400
Message-ID: <1181737935.4050.87.camel@localhost>
References: <466DEF9D.9070509@trash.net>
	 <1181615384.4071.121.camel@localhost>	<466E9DF2.9010505@trash.net>
	 <20070612.140240.00078635.davem@davemloft.net> <466F0D74.5030308@trash.net>
	 <1181714168.4758.57.camel@debian.sh.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.229]:24603 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756266AbXFMMcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 08:32:19 -0400
Received: by wx-out-0506.google.com with SMTP id t15so168534wxc
        for <netdev@vger.kernel.org>; Wed, 13 Jun 2007 05:32:18 -0700 (PDT)
In-Reply-To: <1181714168.4758.57.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-13-06 at 13:56 +0800, Zhu Yi wrote:

> The key argument for Jamal's solution is the NIC will send out 32
> packets in the full PHL in a reasonably short time (a few microsecs per
> Jamal's calculation). But for wireless, the PHL hardware has low
> probability to seize the wireless medium when there are full of high
> priority frames in the air. That is, the chance for transmission in PHL
> and PHH is not equal. Queuing packets in software will starve high
> priority packets than putting them to PHH as early as possible.
> 

The key arguement i make (from day one actually) is to leave the
majority of the work to the driver.
My view of wireless WMM etc is it is a different media behavior
(compared to wired ethernet) which means a different view of strategy
for when it opens the valve to allow in more packets. 802.11 media has
embedded signalling which is usable. Guy Cohen gave a good use case
which i responded to. Do you wanna look at that and respond?

cheers,
jamal

