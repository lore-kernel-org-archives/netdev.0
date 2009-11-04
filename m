From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] e1000: the power down when running ifdown command
Date: Wed, 4 Nov 2009 08:08:46 -0800
Message-ID: <20091104080846.5bf4d225@nehalam>
References: <4AEC05E8.40600@miraclelinux.com>
	<20091031105838.0d4b59a2@nehalam>
	<4AEE35D2.4000503@miraclelinux.com>
	<4AF1562F.8010401@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	davem@davemloft.net, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, svaidy@linux.vnet.ibm.com,
	e1000-devel@lists.sourceforge.net
To: Naohiro Ooiwa <nooiwa@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42587 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756864AbZKDQJH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2009 11:09:07 -0500
In-Reply-To: <4AF1562F.8010401@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 04 Nov 2009 19:23:43 +0900
Naohiro Ooiwa <nooiwa@miraclelinux.com> wrote:

> Naohiro Ooiwa wrote:
> > Stephen Hemminger wrote:
> >> On Sat, 31 Oct 2009 18:39:52 +0900
> >> Naohiro Ooiwa <nooiwa@miraclelinux.com> wrote:
> >>
> >> Does this work with Wake On Lan? 
> > 
> > Yes, it works WOL.
> 
> Sorry, I made a mistake.
> The WOL doesn't work when my patch applied to kernel.
> I wasn't myself.
> 
> I consider the WOL and I will resent the patch.
> Thank you for your point.
> 
> 
> thanks,
> Naohiro Ooiwa


Good, thank you for checking. I like the idea of powering down the
PHY. Some of the drivers have shutdown hooks to power PHY back on
during shutdown to enable WOL.


-- 
