From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: What makes a good fake MAC address?
Date: Wed, 22 Apr 2009 16:35:52 -0700
Message-ID: <200904221635.52875.inaky@linux.intel.com>
References: <20090423070442.1e643b5b.ipng@69706e6720323030352d30312d31340a.nosense.org> <200904221538.10964.inaky@linux.intel.com> <20090422155909.0d2fdffd@s6510>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:2650 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750755AbZDVXfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 19:35:52 -0400
In-Reply-To: <20090422155909.0d2fdffd@s6510>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 22 April 2009, Stephen Hemminger wrote:
> On Wed, 22 Apr 2009 15:38:10 -0700
>
> > > You need a from address for the bridge to be able to populate its
> > > forwarding table. If remote end is always same, just get some random
> > > address at start of tunnel and reuse it.
> >
> > Nope, the remote end will change as you move around from base station
> > to base station :(
>
> Then don't bridge.

heh :) I'll give a try to just try an address from random_ether_addr(), 
it might work

Thanks!

-- 
Inaky
