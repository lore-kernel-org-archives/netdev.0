From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH] ieee1394: eth1394: use "firewire%d" instead of "eth%d" as
 interface name
Date: Sun, 24 May 2009 11:47:04 +0200 (CEST)
Message-ID: <tkrat.6c3758bf0544a790@s5r6.in-berlin.de>
References: <tkrat.21c425cc195510c9@s5r6.in-berlin.de>
 <20090521134856.GA3457@psychotron.englab.brq.redhat.com>
 <4A1565B6.10907@s5r6.in-berlin.de>
 <alpine.DEB.2.01.0905232309400.7424@bogon>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=us-ascii
Cc: linux-kernel@vger.kernel.org,
	linux1394-devel@lists.sourceforge.net,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org
To: Christian Kujau <lists@nerdbynature.de>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.01.0905232309400.7424@bogon>
Content-Disposition: INLINE
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christian Kujau wrote at LKML:
> If the patch will be accepted at all and it's not too late to ask: I'd 
> vote for fw%d as well, "firefire" just looks too long, for me at least. 

I think I'll leave the driver as it is.
As I just noticed, we would lose interface renaming by udev.
>From udev/extras/rule_generator/75-persistent-net-generator.rules:

  # device name whitelist
  KERNEL!="eth*|ath*|wlan*[0-9]|msh*|ra*|sta*|ctc*|lcs*|hsi*", GOTO="persistent_net_generator_end"

Besides, if we can we should avoid fw%d because this will clash with
udev rules which match KERNEL=="fw*", as in
udev/rules/redhat/40-redhat.rules.
-- 
Stefan Richter
-=====-==--= -=-= ==---
http://arcgraph.de/sr/

