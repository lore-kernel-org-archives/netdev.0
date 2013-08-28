From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net,stable] net: usb: Add HP hs2434 device to ZLP
 exception table
Date: Wed, 28 Aug 2013 18:23:32 -0400 (EDT)
Message-ID: <20130828.182332.824853790331642993.davem@davemloft.net>
References: <20130825182913.2865aa1a8cefe329ab9c7a85@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org, bjorn@mork.no,
	oliver@neukum.org
To: robmatic@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50635 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753141Ab3H1WXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 18:23:33 -0400
In-Reply-To: <20130825182913.2865aa1a8cefe329ab9c7a85@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Gardner <robmatic@gmail.com>
Date: Sun, 25 Aug 2013 18:29:13 -0600

> From 018343ce2e679d97283fb51da25c43aa876d087a Mon Sep 17 00:00:00 2001
> From: Rob Gardner <robmatic@gmail.com>
> Date: Sun, 25 Aug 2013 16:02:23 -0600
> Subject: [PATCH net,stable] net: usb: Add HP hs2434 device to ZLP exception table
> 
> This patch adds another entry (HP hs2434 Mobile Broadband) to the list
> of exceptional devices that require a zero length packet in order to
> function properly. This list was added in commit 844e88f0. The hs2434
> is manufactured by Sierra Wireless, who also produces the MC7710,
> which the ZLP exception list was created for in the first place. So
> hopefully it is just this one producer's devices that will need this
> workaround.
> 
> Tested on a DM1-4310NR HP notebook, which does not function without this
> change.
> 
> Signed-off-by: Rob Gardner <robmatic@gmail.com>

Applied and queued up for -tablt, thanks.

On the topic of dealing with detection of this issue, how harmful is the
workaround on chips that don't need it?  Will the driver not work in that
case?
