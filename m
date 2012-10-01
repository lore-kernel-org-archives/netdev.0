From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ti cpsw ethernet: allow reading phy interface
 mode from DT
Date: Mon, 01 Oct 2012 17:38:13 -0400 (EDT)
Message-ID: <20121001.173813.2159935016069621238.davem@davemloft.net>
References: <1348680268-8194-1-git-send-email-zonque@gmail.com>
	<20121001.171114.1093867649404020043.davem@davemloft.net>
	<506A07FA.5000800@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	mugunthanvnm@ti.com, hvaibhav@ti.com
To: zonque@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41423 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099Ab2JAViP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 17:38:15 -0400
In-Reply-To: <506A07FA.5000800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <zonque@gmail.com>
Date: Mon, 01 Oct 2012 23:15:38 +0200

> On 01.10.2012 23:11, David Miller wrote:
>> From: Daniel Mack <zonque@gmail.com>
>> Date: Wed, 26 Sep 2012 19:24:27 +0200
>> 
>>> Allow users to specify the phy interface of the CPSW slaves. The new
>>> node parameter is called "phy_if_mode" and is optional. The original
>>> behaviour of the driver is preserved when not given.
>>>
>>> Signed-off-by: Daniel Mack <zonque@gmail.com>
>> 
>> Applied, thanks.
>> 
> 
> Eh, no - sorry. My original understanding was that a bit in the cpsw
> registers has to be set only when a certain physical phy mode is in use.
> Hence we would have needed a way to pass that information in via DT. But
> as Mugunthan pointed out, that bit must always be set, and the cpsw
> slaves can stay agnostic to the actual phy mode.
> 
> So that patch isn't needed. Sorry for the confusion.

Ok I'll revert.
