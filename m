From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: What makes a good fake MAC address?
Date: Wed, 22 Apr 2009 14:13:26 -0700
Message-ID: <20090422141326.2f8a419d@s6510>
References: <200904221348.27357.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53878 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754323AbZDVVN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Apr 2009 17:13:28 -0400
In-Reply-To: <200904221348.27357.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Apr 2009 13:48:27 -0700
Inaky Perez-Gonzalez <inaky@linux.intel.com> wrote:

> 
> Hi All
> 
> The Intel i2400m WiMAX driver behaves as an ethernet device, and
> currently when sending packets to the netdev stack, it fakes an
> ethernet header, sets the "from" mac address to zeroes and the "to"
> to it's own MAC address.
> 
> The WiMAX network can be considered to be a point-to-point (up to the
> gateway) connection, all IP based, so there are not MAC addresses
> from our gateway (not to mention that it can change behind us).
> 
> The problem with using a zero mac address is that it confuses the
> bridging software (and maybe others). I was wondering, what would be
> a fake mac address we could put in there that is legal for this kind
> of "faking"? [or the closest thing to legal?]
> 
> Thanks!
> 

You want really want hw to have real mac, but if not use
random_ether_addr()
