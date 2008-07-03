From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] phylib: fix forced mode misbehaviour for aneg off case
Date: Thu, 3 Jul 2008 10:41:43 -0700
Message-ID: <20080703104143.6620e99f@extreme>
References: <20080703171614.GA21126@polina.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:43680 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753106AbYGCRlq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jul 2008 13:41:46 -0400
In-Reply-To: <20080703171614.GA21126@polina.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 3 Jul 2008 21:16:14 +0400
Anton Vorontsov <avorontsov@ru.mvista.com> wrote:

> With disabled autonegotiation and link absence, phylib will place phy
> into the forcing mode, thus will start calling phy_force_reduction().
> That means that for the drivers that are using phylib we can't actually
> set fixed speed for the link.
> 
> For example:
> 
> # ethtool -s eth0 autoneg off speed 1000

FYI autonegotiation is required in gigabit mode per 802 spec.
