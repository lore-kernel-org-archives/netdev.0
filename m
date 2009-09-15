From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: igb bandwidth allocation configuration
Date: Tue, 15 Sep 2009 11:25:31 -0700
Message-ID: <382A478CAD40FA4FB46605CF81FE39F43AE5BFC7@orsmsx507.amr.corp.intel.com>
References: <20090910081844.GA5421@verge.net.au>
	<15ddcffd0909140142n2a110708ld619177c65f4588b@mail.gmail.com>
	<20090915113659.GJ24194@verge.net.au>	<4AAF963D.4060708@voltaire.com>
 <4AAFD690.5040900@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Simon Horman <horms@verge.net.au>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:23807 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755016AbZIOSZb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 14:25:31 -0400
In-Reply-To: <4AAFD690.5040900@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Duyck wrote: 
>Or Gerlitz wrote:
>> I'm was asking/wondering if the Intel NICs have a rate limiter (i.e one 
>> can program the VF such that its rate doesn't exceed XX MB/s) or a "rate 
>> guarantee"  (i.e one can program the VF such that its guaranteed it will 
>> get YY MB/s in case it wants to xmit at least this bandwidth)
>
>Based on the way I am reading the documentation I would say the all 
>these registers do is guarantee a minimum percentage of the bandwidth. 

FYI, the newer 10gig 82599 *does* have a rate limiting feature in hw.  This feature is not currently supported by the ixgbe driver.

sln
