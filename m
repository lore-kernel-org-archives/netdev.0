From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: spidernet: dynamic phy setup code
Date: Fri, 26 Jan 2007 11:58:37 -0600
Message-ID: <20070126175837.GB8489@austin.ibm.com>
References: <200701261409.29537.jens@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org, jgarzik@pobox.com,
	James K Lewis <jim@jklewis.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Jens Osterkamp <jens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:46840 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161108AbXAZR6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 12:58:39 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id l0QHwcMg005411
	for <netdev@vger.kernel.org>; Fri, 26 Jan 2007 12:58:38 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0QHwcxD510734
	for <netdev@vger.kernel.org>; Fri, 26 Jan 2007 10:58:38 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0QHwbYp009123
	for <netdev@vger.kernel.org>; Fri, 26 Jan 2007 10:58:38 -0700
Content-Disposition: inline
In-Reply-To: <200701261409.29537.jens@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 26, 2007 at 02:09:29PM +0100, Jens Osterkamp wrote:
> This patch modifies the patch submitted by Kou Ishizaki to make it work on the
> blade (http://marc.theaimsgroup.com/?l=linux-netdev&m=116593424505539&w=2).
> 
> Index: linux-2.6/drivers/net/spider_net.c
> + if (card->aneg_count > SPIDER_NET_ANEG_TIMEOUT) {
> +
> +  pr_info("%s: link is down, trying to bring it up\n", card->netdev->name);
> +
> +  switch(phy->medium) {
> +  case GMII_COPPER:
> +   /* enable fiber with autonegotiation first */
> +   if (phy->def->ops->enable_fiber)
> +    phy->def->ops->enable_fiber(phy, 1);
> +   phy->medium = GMII_FIBER;
> +   break;

Can you fix this to use tabs for indentation, instead of spaces?

Please note, if you do not like tabs of 8 spaces, you can always
change this in your editor, e.g "set ts=3" for making a tab 
be 3 spaces in vi. You would put this in your .exrc or .vimrc file.

Patches submitted to the kernel should use tabs, uniformly.

--linas
