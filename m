From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [next:akpm 16/587]
 drivers/net/ethernet/intel/igb/igb_main.c:6231:2: error: call to
 '__compiletime_assert_6235' declared with attribute error: BUILD_BUG_ON
 failed: SKB_WITH_OVERHEAD(IGB_RX_BUFSZ) < (NET_SKB_PAD + NET_IP_ALIGN +
 IGB_TS_HDR_LEN + ETH...
Date: Tue, 19 Feb 2013 23:02:17 +0000
Message-ID: <9BBC4E0CF881AA4299206E2E1412B6264EE87950@ORSMSX102.amr.corp.intel.com>
References: <5122101a.nBjTqFyZXZ+WuzPr%fengguang.wu@intel.com>
 <20130219142708.b454d98a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Daniel Santos <daniel.santos@pobox.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	"Wu, Fengguang" <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:57527 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933341Ab3BSXCT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 18:02:19 -0500
In-Reply-To: <20130219142708.b454d98a.akpm@linux-foundation.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Andrew Morton
> Sent: Tuesday, February 19, 2013 2:27 PM
> To: Wu, Fengguang
> Cc: Daniel Santos; Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W;
> netdev@vger.kernel.org
> Subject: Re: [next:akpm 16/587]
> drivers/net/ethernet/intel/igb/igb_main.c:6231:2: error: call to
> '__compiletime_assert_6235' declared with attribute error: BUILD_BUG_ON
> failed: SKB_WITH_OVERHEAD(IGB_RX_BUFSZ) < (NET_SKB_PAD +
> NET_IP_ALIGN + IGB_TS_HDR_LEN + ETH...
> 
[..]

> That BUILD_BUG_ON() triggers without Daniel's patches applied as well:
> 
[..]
> I doubt if anyone will be running this driver on s390, but I guess we should work
> out why it broke.
> 

Yes, we'll work on it.

Thanks,

Carolyn

Carolyn Wyborny 
Linux Development 
Networking Division 
Intel Corporation 
