From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next 3/3] eth: Rename and properly align
 br_reserved_address array
Date: Sun, 4 Nov 2012 12:42:19 -0800
Message-ID: <20121104124219.561a7235@s6510.linuxnetplumber.net>
References: <1351797122.2883.14.camel@bwh-desktop.uk.solarflarecom.com>
	<509314F3.6030206@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39522 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751213Ab2KDUm0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Nov 2012 15:42:26 -0500
In-Reply-To: <509314F3.6030206@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 01 Nov 2012 17:33:55 -0700
John Fastabend <john.r.fastabend@intel.com> wrote:

> On 11/1/2012 12:12 PM, Ben Hutchings wrote:
> > Since this array is no longer part of the bridge driver, it should
> > have an 'eth' prefix not 'br'.
> >
> > We also assume that either it's 16-bit-aligned or the architecture has
> > efficient unaligned access.  Ensure the first of these is true by
> > explicitly aligning it.
> >
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
> 
> Thanks.
> 
> Acked-by: John Fastabend <john.r.fastabend@intel.com>
> 

I wonder if aligning to 64 bit and doing 64 bit read
and mask would be trivially more efficient for this.
