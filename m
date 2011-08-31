From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [net v2] e1000: Fix driver to be used on PA RISC C8000
 workstations
Date: Wed, 31 Aug 2011 08:37:13 -0700
Message-ID: <20110831153713.GC8618@kroah.com>
References: <1314751777-13772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Guy Martin <gmsoft@tuxicoman.be>,
	Matt Turner <mattst88@gmail.com>, gospo@redhat.com,
	Rolf Eike Beer <eike-kernel@sf-tec.de>, stable@kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3.smtp.messagingengine.com ([66.111.4.27]:51134 "EHLO
	out3.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756609Ab1HaPkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 11:40:17 -0400
Content-Disposition: inline
In-Reply-To: <1314751777-13772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 30, 2011 at 05:49:37PM -0700, Jeff Kirsher wrote:
> The checksum field in the EEPROM on HPPA is really not a
> checksum but a signature (0x16d6).  So allow 0x16d6 as the
> matching checksum on HPPA systems.
> 
> This issue is present on longterm/stable kernels, I have
> verified that this patch is applicable back to at least
> 2.6.32.y kernels.
> 
> v2- changed ifdef to use CONFIG_PARISC instead of __hppa__
> 
> CC: Guy Martin <gmsoft@tuxicoman.be>
> CC: Rolf Eike Beer <eike-kernel@sf-tec.de>
> CC: Matt Turner <mattst88@gmail.com>
> Reported-by: Mikulas Patocka <mikulas@artax.kerlin.mff.cuni.cz>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> ---

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>
