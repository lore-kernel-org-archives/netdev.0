From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next 00/14] default maximal number of RSS queues in
 mq drivers
Date: Wed, 20 Jun 2012 22:49:00 -0700 (PDT)
Message-ID: <20120620.224900.468755799466232238.davem@davemloft.net>
References: <1340225015.2576.27.camel@bwh-desktop.uk.solarflarecom.com>
	<1340225323.2576.30.camel@bwh-desktop.uk.solarflarecom.com>
	<4FE2ADF8.8010508@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	eilong@broadcom.com, divy@chelsio.com, ogerlitz@mellanox.com,
	jdmason@kudzu.us, anirban.chakraborty@qlogic.com,
	jitendra.kalsaria@qlogic.com, ron.mercer@qlogic.com,
	jeffrey.t.kirsher@intel.com, mason@myri.com, gallatin@myri.com,
	sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, mcarlson@broadcom.com, mchan@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49348 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755354Ab2FUFtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 01:49:07 -0400
In-Reply-To: <4FE2ADF8.8010508@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Thu, 21 Jun 2012 08:15:36 +0300

> On 06/20/2012 11:48 PM, Ben Hutchings wrote:
> 
>> Also, I would recommend encapsulating the calculation of default number
>> of RSS queues in a function, rather than repeating it in every driver.
>> That will make it easier to replace with something more sophisticated
>> and configurable later on.
>> 
>> Ben.
>> 
> 
> Do You also have the notion of where's the correct place to place such a
> function?

I would put the extern declaration into linux/netdevice.h and the
implementation in net/core/dev.c
