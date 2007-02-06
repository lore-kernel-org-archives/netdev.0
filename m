From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 5/7] sky2: Yukon Extreme support
Date: Tue, 6 Feb 2007 14:07:44 -0800
Message-ID: <20070206140744.5164dcff@oldman>
References: <20070206184538.675048000@linux-foundation.org>
	<20070206184855.246345000@linux-foundation.org>
	<20070206215256.GA28967@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:53010 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965545AbXBFWMG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 17:12:06 -0500
In-Reply-To: <20070206215256.GA28967@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> static bool is_yukon_extreme(struct sky2_hw *hw)
> {
> 	return hw->chip_id == CHIP_ID_YUKON_XL ||
> 		hw->chip_id == CHIP_ID_YUKON_EC_U ||
> 		hw->chip_id == CHIP_ID_YUKON_EX;

These chips aren't "extreme", it might be easier to turn the
test around and test for the chips that aren't that way.
