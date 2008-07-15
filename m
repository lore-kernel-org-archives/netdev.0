From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: Re: [PATCH RFC 03/10] mlx4_en: net_device implementation
Date: Tue, 15 Jul 2008 18:01:03 +0300
Message-ID: <487CBBAF.9030704@mellanox.co.il>
References: <487B657E.2040900@mellanox.co.il> <20080714194228.GU19302@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.co.il>, tziporet@mellanox.co.il,
	Roland Dreier <rdreier@cisco.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:34734 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755178AbYGOPCH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2008 11:02:07 -0400
In-Reply-To: <20080714194228.GU19302@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> 
> This is already under RTNL; why do you need your own semaphore?
> (And why are you using semaphores, not mutexes?)

We approach the device/port state from many functions, not all protected by the
RTNL lock.
You are right about the mutex, it needs to be changed.

Yevgeny
