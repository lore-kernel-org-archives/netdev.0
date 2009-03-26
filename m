From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3] igbvf: add new driver to support 82576
 virtual functions
Date: Wed, 25 Mar 2009 20:16:35 -0700 (PDT)
Message-ID: <20090325.201635.245115032.davem@davemloft.net>
References: <20090325.165847.234084422.davem@davemloft.net>
	<49CAD25F.4080705@intel.com>
	<20090326023343.GA8138@yzhao-otc.sh.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, alexander.h.duyck@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com
To: yu.zhao@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52108
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753928AbZCZDQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 23:16:49 -0400
In-Reply-To: <20090326023343.GA8138@yzhao-otc.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yu Zhao <yu.zhao@intel.com>
Date: Thu, 26 Mar 2009 10:33:43 +0800

> We do have some powerful tools for network device configuration, but
> they still can't cover the multi queue and SR-IOV NICs (also David
> Woodhouse's Solos DSL, etc.) configuration requirement.

We have a generic link creation mechanism in rtnl_link so I think
this claim wrt. SR-IOV is false.

Believe it or not, somebody took the time to make a generic mechanism
for things many virtual network device drivers have to do, and
igb/igbvf can use it too.
