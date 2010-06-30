From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH] igbvf: avoid name clash between PF and VF
Date: Wed, 30 Jun 2010 09:59:36 -0700
Message-ID: <201006300959.37145.leedom@chelsio.com>
References: <4C2B0614.9040004@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, e1000-devel@lists.sourceforge.net,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	gregory.v.rose@intel.com, jeffrey.t.kirsher@intel.com,
	Andy Gospodarek <gospo@redhat.com>
To: Stefan Assmann <sassmann@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:25214 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754769Ab0F3RA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 13:00:57 -0400
In-Reply-To: <4C2B0614.9040004@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: Stefan Assmann <sassmann@redhat.com>
| Date: Wednesday, June 30, 2010 01:53 am
| 
| This is not a udev bug since udev doesn't create persistent rules for
| VFs as their MAC address changes every reboot.
| 
| To avoid this problem we could change the kernel name for the VFs and
| thus avoid confusion between VFs and PFs.
| 
| I've already discussed this with Alexander Duyck and Greg Rose, so far
| they have no objection. However this problem appears for all drivers that
| support PFs and VFs and thus the changes should be applied consistently
| to all of these drivers.

  I'm not sure that this problem affects "all drivers which support PFs and VFs."  
I think that you might mean "all drivers which support PFs and VFs with non-
persistent MAC addresses for the VFs."  For instance, the MAC addresses 
associated with the new cxgb4vf VFs are persistent so, from what I understand of 
the scenario you outlined, I don't think that they would trigger the problem you 
describe.  Please correct me if I've missed something.  Thanks.

Casey
