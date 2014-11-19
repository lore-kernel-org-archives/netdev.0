From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: team: expose sysfs attributes for each team option
Date: Wed, 19 Nov 2014 13:24:19 -0500 (EST)
Message-ID: <20141119.132419.615870013166580191.davem@davemloft.net>
References: <93856491220bda9aede41a9571fb1ac1.squirrel@www.codeaurora.org>
	<20141117130201.GB1872@nanopsycho.orion>
	<03067d01f18e264b30f86d0307d11b07.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org
To: hkadmany@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37306 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759AbaKSSYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 13:24:22 -0500
In-Reply-To: <03067d01f18e264b30f86d0307d11b07.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Hamad Kadmany" <hkadmany@codeaurora.org>
Date: Wed, 19 Nov 2014 12:28:19 -0000

> Using team driver requires using libnl3. In Android based platforms,
> libnl3 is not supported, and libnl3 license poses constraints in
> Android's user-space.
> 
> This is the reason for the this change, to have at least the team
> options exposed through sysfs.

That's a completely and utterly bogus argument for duplicating
functionality in the kernel.  You could more easily write a license
compatible version of whatever userland component you need.

Seriously, this is not our problem.
