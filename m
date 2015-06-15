From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rocker: gaurd against NULL rocker_port when
 removing ports
Date: Mon, 15 Jun 2015 16:04:33 -0700 (PDT)
Message-ID: <20150615.160433.311053724510623343.davem@davemloft.net>
References: <1434168584-61990-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42312 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392AbbFOXEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 19:04:34 -0400
In-Reply-To: <1434168584-61990-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Fri, 12 Jun 2015 21:09:44 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> The ports array is filled in as ports are probed, but if probing doesn't
> finish, we need to stop only those ports that where probed successfully.
> Check the ports array for NULL to skip un-probed ports when stopping.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Applied.
