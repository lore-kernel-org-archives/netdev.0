From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 08/15] i40e: Allow user to change input set mask for
 flow director
Date: Wed, 04 May 2016 23:57:29 -0400 (EDT)
Message-ID: <20160504.235729.1697828176137158687.davem@davemloft.net>
References: <1461704148-114349-9-git-send-email-jeffrey.t.kirsher@intel.com>
	<20160426.234814.31916479145118247.davem@davemloft.net>
	<572AB43E.2020007@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: kiran.patil@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48071 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755284AbcEED5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 23:57:33 -0400
In-Reply-To: <572AB43E.2020007@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Patil, Kiran" <kiran.patil@intel.com>
Date: Wed, 4 May 2016 19:47:26 -0700

> This is not new feature implemented in i40e driver. This is the
> original feature of ethtool which allows user to specify subset of
> tuple for setting up flow director.

Where is the interpretation of this special value defined in the
ethtool headers?

If it doesn't even have a macro for that magic constant value, it's
not part of the interface at all.

If the only other example of doing this trick is another Intel driver,
that lends even less credence to your arguments that this is a defined
interface.  Rather, it makes it look even more like an Intel specific
behavior.  Vendor specific behaviors of interfaces is exactly what we
are trying to avoid.
