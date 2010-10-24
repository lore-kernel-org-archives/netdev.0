From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] typhoon: wait for RX mode commands to finish
Date: Sun, 24 Oct 2010 16:26:31 -0700 (PDT)
Message-ID: <20101024.162631.27796142.davem@davemloft.net>
References: <1287951621-25170-1-git-send-email-dave@thedillows.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dave@thedillows.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32884
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750996Ab0JXX0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 19:26:08 -0400
In-Reply-To: <1287951621-25170-1-git-send-email-dave@thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Dillow <dave@thedillows.org>
Date: Sun, 24 Oct 2010 16:20:20 -0400

> When adding VLAN devices, we can get several calls to
> typhoon_set_rx_mode() in quick succession. Because we didn't wait for
> the commands to complete, we could run out of command descriptors and
> fail to set the RX mode.
> 
> Signed-off-by: David Dillow <dave@thedillows.org>

Applied.
