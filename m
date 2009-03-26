From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [net-next PATCH v3] igbvf: add new driver to support 82576 virtual functions
Date: Wed, 25 Mar 2009 20:21:08 -0700
Message-ID: <ada4oxhufyz.fsf@cisco.com>
References: <49CAB13B.7070601@intel.com>
	<20090325.165847.234084422.davem@davemloft.net>
	<49CAD25F.4080705@intel.com>
	<20090325.201219.98810772.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexander.h.duyck@intel.com, shemminger@vyatta.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:45610 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755193AbZCZDVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 23:21:11 -0400
In-Reply-To: <20090325.201219.98810772.davem@davemloft.net> (David Miller's
	message of "Wed, 25 Mar 2009 20:12:19 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > > Since the issue isn't the igbvf driver there is no reason for it to
 > > be held up.
 > 
 > I disagree, I think both cases should be fixed.
 > 
 > Just because we do something already never means that it's
 > ok to proliferate the mistake further.

The igbvf driver doesn't proliferate any mistake.  The num_vfs sysfs
attribute that everyone finds so objectionable is in the igb driver, and
if you follow the patchwork URL that was provided, you would see that
you applied the patch adding it back in February.  The only thing the
igbvf driver does relating to this is bind to the PCI ID of the virtual
functions created by the igb driver.

 - R.
