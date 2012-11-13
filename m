From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: Update hard_header_len based on lowerdev when
 instantiating VXLAN
Date: Tue, 13 Nov 2012 18:20:10 -0500 (EST)
Message-ID: <20121113.182010.61623496024610622.davem@davemloft.net>
References: <20121113133353.227ec987@nehalam.linuxnetplumber.net>
	<20121113230955.16102.62399.stgit@ahduyck-cp1.jf.intel.com>
	<20121113151200.16afce74@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51135 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753338Ab2KMXUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 18:20:12 -0500
In-Reply-To: <20121113151200.16afce74@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 13 Nov 2012 15:12:00 -0800

> On Tue, 13 Nov 2012 15:10:59 -0800
> Alexander Duyck <alexander.h.duyck@intel.com> wrote:
> 
>> In the event of a VXLAN device being linked to a device that has a
>> hard_header_len greater than that of standard ethernet we could end up with
>> the hard_header_len not being large enough for outgoing frames.  In order to
>> prevent this we should update the length when a lowerdev is provided.
>> 
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
 ...
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
