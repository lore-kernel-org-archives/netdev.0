From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [ethtool PATCH 4/4] v5 Add RX packet classification interface
Date: Wed, 04 May 2011 12:06:12 -0700
Message-ID: <4DC1A3A4.20900@chelsio.com>
References: <20110503160547.29251.84333.stgit@gitlad.jf.intel.com>	 <20110503161226.29251.40838.stgit@gitlad.jf.intel.com>	 <4DC08E7B.7070906@chelsio.com> <1304465684.2873.26.camel@bwh-desktop>	 <4DC1883F.7050301@chelsio.com> <1304529892.2926.14.camel@bwh-desktop>	 <4DC18DF8.3090707@chelsio.com>  <4DC18FB2.8060604@intel.com> <1304532342.2926.46.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:10279 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752327Ab1EDTGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 15:06:21 -0400
In-Reply-To: <1304532342.2926.46.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2011 11:05 AM, Ben Hutchings wrote:
> How about having ETHTOOL_GRXCLSRLCNT set a flag in the 'data' field to
> indicate that the driver can assign locations?  (We would have to
> specify that for compatibility with older kernels the application must
> initialise this filed to 0.)
> 
> rmgr_init() would then check for this flag.

I think this is a good suggestion if we want to support location selection by 
either the driver or ethtool.  I also think ethtool's assumption that it is the 
only allocator and can allocate race-free is fundamentally flawed (take two 
parallel ethtools).
