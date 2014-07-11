From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2] ipv6: addrconf: implement address
 generation modes
Date: Fri, 11 Jul 2014 15:06:08 -0700 (PDT)
Message-ID: <20140711.150608.2139135205801597614.davem@davemloft.net>
References: <1405105818-1460-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	sfeldma@cumulusnetworks.com, arvid.brodin@alten.se,
	sucheta.chakraborty@qlogic.com, hannes@stressinduktion.org,
	stephen@networkplumber.org, dcbw@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754634AbaGKWGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 18:06:09 -0400
In-Reply-To: <1405105818-1460-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 11 Jul 2014 21:10:18 +0200

> This patch introduces a possibility for userspace to set various (so far
> two) modes of generating addresses. This is useful for example for
> NetworkManager because it can set the mode to NONE and take care of link
> local addresses itself. That allow it to have the interface up,
> monitoring carrier but still don't have any addresses on it.
> 
> One more use-case by Dan Williams:
> <quote>
> WWAN devices often have their LL address provided by the firmware of the
> device, which sometimes refuses to respond to incorrect LL addresses
> when doing DHCPv6 or IPv6 ND.  The kernel cannot generate the correct LL
> address for two reasons:
> 
> 1) WWAN pseudo-ethernet interfaces often construct a fake MAC address,
> or read a meaningless MAC address from the firmware.  Thus the EUI64 and
> the IPv6LL address the kernel assigns will be wrong.  The real LL
> address is often retrieved from the firmware with AT or proprietary
> commands.
> 
> 2) WWAN PPP interfaces receive their LL address from IPV6CP, not from
> kernel assignments.  Only after IPV6CP has completed do we know the LL
> address of the PPP interface and its peer.  But the kernel has already
> assigned an incorrect LL address to the interface.
> 
> So being able to suppress the kernel LL address generation and assign
> the one retrieved from the firmware is less complicated and more robust.
> </quote>
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied, thanks Jiri.
