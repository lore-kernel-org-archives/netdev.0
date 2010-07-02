From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH ethtool 2/2] ethtool: Add support for control of RX flow
 hash indirection
Date: Fri, 02 Jul 2010 03:25:00 -0400
Message-ID: <4C2D944C.80604@garzik.org>
References: <1277910740.2082.17.camel@achroite.uk.solarflarecom.com> <1277910792.2082.18.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@redhat.com>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:57687 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754767Ab0GBHZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 03:25:04 -0400
Received: by gye5 with SMTP id 5so265541gye.19
        for <netdev@vger.kernel.org>; Fri, 02 Jul 2010 00:25:03 -0700 (PDT)
In-Reply-To: <1277910792.2082.18.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/30/2010 11:13 AM, Ben Hutchings wrote:
> Many NICs use an indirection table to map an RX flow hash value to one
> of an arbitrary number of queues (not necessarily a power of 2).  It
> can be useful to remove some queues from this indirection table so
> that they are only used for flows that are specifically filtered
> there.  It may also be useful to weight the mapping to account for
> user processes with the same CPU-affinity as the RX interrupts.
>
> Signed-off-by: Ben Hutchings<bhutchings@solarflare.com>

applied 1-2, after making requested printf correction


