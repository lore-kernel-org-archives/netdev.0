From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: spidernet: add improved phy support in sungem_phy.c
Date: Sat, 27 Jan 2007 07:20:47 +1100
Message-ID: <1169842847.24996.106.camel@localhost.localdomain>
References: <200701261407.48237.jens@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org,
	Linas Vepstas <linas@austin.ibm.com>, jgarzik@pobox.com,
	James K Lewis <jim@jklewis.com>
To: Jens Osterkamp <jens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:53169 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161167AbXAZU2U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jan 2007 15:28:20 -0500
In-Reply-To: <200701261407.48237.jens@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-01-26 at 14:07 +0100, Jens Osterkamp wrote:
> This patch adds improved version of enable_fiber for both the 5421 and
> the 5461 phy. It is now possible to specify with these wether you want
> autonegotiation or not. This is needed for bladecenter switches where
> some expect autonegotiation and some dont seem to like this at all.
> Depending on this flag it sets phy->autoneg accordingly for the fiber mode.
> 
> More importantly it implements proper read_link and poll_link functions
> for both phys which can handle both copper and fiber mode by determining
> the medium first and then branching to the required functions. For fiber
> they all work fine, for copper they are not tested but return the result
> of the genmii_* function anyway which is supposed to work.
> 
> A "medium" variable in the phy struct is introduced to save the medium
> with which the phy is currently used.
> 
> The patch moves the genmii_* functions around to avoid foreward declarations.
> 
> Signed-off-by: Jens Osterkamp <jens@de.ibm.com>
> Signed-off-by: Arnd Bergmann <arnd.bergmann@de.ibm.com>

Patch is whitespace damaged...

Ben.


