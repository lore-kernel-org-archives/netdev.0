From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: IPv6 stops working after ethtool diagnostic
Date: Tue, 15 Jun 2010 12:25:39 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FF43AAD92@rrsmsx501.amr.corp.intel.com>
References: <EA929A9653AAE14F841771FB1DE5A1365FF43AAD0F@rrsmsx501.amr.corp.intel.com>
 <1276625792.2078.12.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:40744 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755553Ab0FOSZl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 14:25:41 -0400
In-Reply-To: <1276625792.2078.12.camel@achroite.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> On Tue, 2010-06-15 at 12:05 -0600, Tantilov, Emil S wrote:
>> We ran into a problem on net-next where IPv6 traffic fails after
>> running ethtool -t: 
> 
> Are you going to report which driver is responsible for eth0 or are
> are you going to let us guess?

Yeah - should've mention that. In my tests so far this does not appear to be driver specific issue. I was able to reproduce with e1000e, igb, ixgbe and bnx2.

Thanks,
Emil

