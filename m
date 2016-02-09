From: David Miller <davem@davemloft.net>
Subject: Re: [Intel-wired-lan] [next] igb: allow setting MAC address on
 i211 using a device tree blob
Date: Tue, 09 Feb 2016 17:10:48 -0500 (EST)
Message-ID: <20160209.171048.159766540065134460.davem@davemloft.net>
References: <1455015744.3592.46.camel@intel.com>
	<20160209115921.GE18781@lunn.ch>
	<CAP-MU4Mr5SkpC9XZuPa5xaAjgJ+_j3Gt5hYcSO6a2Q7jVB8HcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, jeffrey.t.kirsher@intel.com, jotihojr@gmail.com,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: shannon.nelson@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59057 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932682AbcBIWKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 17:10:52 -0500
In-Reply-To: <CAP-MU4Mr5SkpC9XZuPa5xaAjgJ+_j3Gt5hYcSO6a2Q7jVB8HcQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>
Date: Tue, 9 Feb 2016 09:42:45 -0800

> It seem to me this should be using eth_platform_get_mac_address(), a
> slightly more generic method to do this.  See the i40e driver for an
> example, commit d9a84324e6 I believe.

+1
