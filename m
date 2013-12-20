From: Joe Perches <joe@perches.com>
Subject: Re: [net-next v3 14/16] i40e: make a define from a large constant
Date: Fri, 20 Dec 2013 14:12:37 -0800
Message-ID: <1387577557.2353.62.camel@joe-AO722>
References: <1387563694-3166-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1387563694-3166-15-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1387564814.2353.60.camel@joe-AO722>
	 <1387570331.2183.97.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0008.hostedemail.com ([216.40.44.8]:39571 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753569Ab3LTWMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 17:12:41 -0500
In-Reply-To: <1387570331.2183.97.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-20 at 12:12 -0800, Jeff Kirsher wrote:
> On Fri, 2013-12-20 at 10:40 -0800, Joe Perches wrote:
> > On Fri, 2013-12-20 at 10:21 -0800, Jeff Kirsher wrote:
> > > Make a define used in the header file by both VF and PF drivers.
> > []
> > > diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
> > []
> > > @@ -66,6 +66,26 @@ enum i40e_dyn_idx_t {
> > []
> > > +/* Supported RSS offloads */
> > > +#define I40E_DEFAULT_RSS_HENA ( \
> > > +	((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP) | \
> > 
> > BIT_ULL
> > 
> > > +	((u64)1 << I40E_FILTER_PCTYPE_NONF_MULTICAST_IPV4_UDP) | \
> > 
> > etc...
> > 
> 
> Joe, I am not seeing widespread use of the macro BIT_ULL, so what is the
> driving factor to use the macro?

Hey Jeff.

It was just introduced in October 2013.

commit bfd1ff6375c82930bfb3b401eee2c96720fa8e84
Author: Srinivas Pandruvada <srinivas.pandruvada@linux.intel.com>
Date:   Fri Oct 11 16:54:59 2013 -0700

    bitops: Introduce BIT_ULL
    
    Adding BIT(x) equivalent for unsigned long long type, BIT_ULL(x). Also
    added BIT_ULL_MASK and BIT_ULL_WORD.
    

>   I know you mentioned this on a
> previous patch I pushed and wanted to ask then, but simply forgot.

Just consistency and symmetry and a few
bug reduction possibilities using standard
mechanisms.
