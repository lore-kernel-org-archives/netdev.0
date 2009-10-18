From: Harald Welte <laforge@gnumonks.org>
Subject: Re: PF_RING: Include in main line kernel?
Date: Sun, 18 Oct 2009 14:45:06 +0200
Message-ID: <20091018124506.GF27747@prithivi.gnumonks.org>
References: <8B385E10-4BE2-48A6-BDE0-0AA1A603275E@ntop.org>
 <20091014203640.GB32317@ioremap.net>
 <4AD64251.50903@candelatech.com>
 <20091014.144923.112167161.davem@davemloft.net>
 <20091015070234.GA29506@ioremap.net>
 <4AD74EF1.6080106@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, deri@ntop.org,
	shemminger@vyatta.com, brad.doctor@gmail.com,
	netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:60309 "EHLO
	ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754485AbZJRMrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 08:47:18 -0400
Content-Disposition: inline
In-Reply-To: <4AD74EF1.6080106@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On Thu, Oct 15, 2009 at 09:33:53AM -0700, Ben Greear wrote:

> Bonding, bridging, mac-vlans, pktgen-rx logic, sniffers, and others could.
> The only trick is ordering...it may be better to keep the hard-coded hooks in
> a definite order than to allow users to switch them around.

why does this sound like the netfilter hooks with their priorities to me?  The
only difference is that netfilter hooks are inside the layer 3 protocols at the
moment, whereas this is one layer lower...

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
