From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general][PATCH] mlx4_core: Synch catastrophic flow with
 module unload
Date: Mon, 13 Jul 2009 11:14:07 -0700 (PDT)
Message-ID: <20090713.111407.196601373.davem@davemloft.net>
References: <4A5B5274.2020801@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56228
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755854AbZGMSOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2009 14:14:03 -0400
In-Reply-To: <4A5B5274.2020801@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 13 Jul 2009 18:27:48 +0300

> There is a race condition when the mlx4_core module is being unloaded
> during the execution of restart task due to catastrophic error.
> Added a global mutex that synchs those operations. If the catastrophic task
> tries to catch the mutex, and it is already taken, it means that somebody is unloading the
> module, and there is no point in executing the restart operation.
> If the unload function tries to catch the mutex and it is taken,
> it would wait for the catas task to finish and then unload the module.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied, thanks.
