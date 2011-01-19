From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: Question on RX packet classification in ethtool userspace
Date: Wed, 19 Jan 2011 14:52:48 -0800
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F25C04CB6B2@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"santwona.behera@sun.com" <santwona.behera@sun.com>,
	"jeff@garzik.org" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:63598 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751781Ab1ASWw6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 17:52:58 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So I was looking into the option of replacing the ETHTOOL_GRXNTUPLE call with something like ETHTOOL_GRXCLSRLALL and it seems like I wasn't having much luck finding the userspace implementation in the ethtool.

I eventually found a patch in patchwork at http://patchwork.ozlabs.org/patch/23223/ which is supposed to add support but the current ethtool git tree doesn't appear to contain this code.  I was wondering if I am missing something and it is on a branch somewhere, or is this something that was not applied to the userspace for some specific reason?

Thanks,

Alex
