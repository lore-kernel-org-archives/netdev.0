From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/11] default maximal number of RSS queues in
 mq drivers
Date: Thu, 05 Jul 2012 03:07:38 -0700 (PDT)
Message-ID: <20120705.030738.1582003570606539876.davem@davemloft.net>
References: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, divy@chelsio.com,
	ogerlitz@mellanox.com, jdmason@kudzu.us,
	anirban.chakraborty@qlogic.com, jitendra.kalsaria@qlogic.com,
	ron.mercer@qlogic.com, jeffrey.t.kirsher@intel.com, mason@myri.com,
	gallatin@myri.com, sathya.perla@emulex.com,
	subbu.seetharaman@emulex.com, ajit.khaparde@emulex.com,
	mcarlson@broadcom.com, mchan@broadcom.com, eric.dumazet@gmail.com,
	bhutchings@solarflare.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55062 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755743Ab2GEKHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 06:07:40 -0400
In-Reply-To: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Sun, 1 Jul 2012 16:18:49 +0300

> Different vendors support different number of RSS queues by default. Today,
> there exists an ethtool API through which users can change the number of
> channels their driver supports; This enables us to pursue the goal of using
> a default number of RSS queues in various multi-queue drivers.
> 
> This patch intendeds to achieve the above default, by upper-limiting the number
> of interrupts multi-queue drivers request (by default, not via the new API) 
> with correlation to the number of cpus on the machine.

Applied to net-next, thanks a lot.
