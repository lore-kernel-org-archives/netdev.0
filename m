From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Thu, 29 Nov 2007 08:53:34 -0800
Message-ID: <20071129085334.5793a922@laptopd505.fenrus.org>
References: <20071122343.446909000@suse.de>
	<adatznarrzc.fsf@cisco.com>
	<200711261228.15155.rusty@rustcorp.com.au>
	<20071126102533.1c774870@freepuppy.rosehill.pdx.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Roland Dreier <rdreier@cisco.com>, Andi Kleen <ak@suse.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:33863 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757301AbXK2Qy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 11:54:59 -0500
In-Reply-To: <20071126102533.1c774870@freepuppy.rosehill.pdx.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 26 Nov 2007 10:25:33 -0800
> 
> Agreed. On first glance, I was intrigued but:
> 
> 1) Why is everyone so concerned that export symbol space is large?
> 	- does it cost cpu or running memory?

yes. about 120 bytes per symbol

> 	- does it cause bugs?

yes, bad apis are causing bugs... sys_open is just the starter of that.


-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
