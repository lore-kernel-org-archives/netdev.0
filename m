From: Andi Kleen <ak@suse.de>
Subject: Re: forcedeth driver NAPI?
Date: Tue, 2 May 2006 21:35:53 +0200
Message-ID: <200605022135.53580.ak@suse.de>
References: <200605021549.47719.netdev@axxeo.de> <20060502121151.63786a86@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ingo Oeser <netdev@axxeo.de>,
	Manfred Spraul <manfred@colorfullife.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:60628 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1751050AbWEBTgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 May 2006 15:36:02 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060502121151.63786a86@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 02 May 2006 21:11, Stephen Hemminger wrote:
> Has anyone looked into making this driver use NAPI?  This would fix
> the IRQ overload problem and a number of other DoS risks.
> Also, if done right the device lock could be reduced to just
> a transmit lock.

Making it support netpoll would be nice too.

-Andi
