From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] netlink: nla_nest_end return "unsigned init"
Date: Mon, 16 May 2011 13:51:10 -0400 (EDT)
Message-ID: <20110516.135110.1328027948753436190.davem@davemloft.net>
References: <1305555810-17565-1-git-send-email-wey-yi.w.guy@intel.com>
	<20110516173548.GB6551@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wey-yi.w.guy@intel.com, linux-wireless@vger.kernel.org,
	ipw3945-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38725 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740Ab1EPRwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 13:52:31 -0400
In-Reply-To: <20110516173548.GB6551@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 16 May 2011 13:35:48 -0400

> This should go to netdev@vger.kernel.org instead...
> 
> On Mon, May 16, 2011 at 07:23:30AM -0700, Wey-Yi Guy wrote:
>> skb->len has unsigned int, return the correct value from nla_nest_end call.
>> 
>> Signed-off-by: Wey-Yi Guy <wey-yi.w.guy@intel.com>

Plus, the only users of the return value use it to feed "int"
return values of functions.  F.e. net/core/neighbour.c's use
in neightbl_fill_parms().

I don't see this as being any better or worse, and we should
just leave the return value alone.
