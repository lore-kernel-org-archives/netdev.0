From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: fix cipso packet validation when !NETLABEL
Date: Thu, 17 Oct 2013 15:47:42 -0400 (EDT)
Message-ID: <20131017.154742.370913034142395176.davem@davemloft.net>
References: <2291823.ee0I8c00DA@olly>
	<0DB595A2CB707F458400BE9663B6A72269C00479DF@SC-VEXCH2.marvell.com>
	<3511324.zOrNRFllMJ@sifl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: seif@marvell.com, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com, dima@marvell.com
To: paul@paul-moore.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46561 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759183Ab3JQTro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 15:47:44 -0400
In-Reply-To: <3511324.zOrNRFllMJ@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul@paul-moore.com>
Date: Mon, 14 Oct 2013 11:12:47 -0400

> On Saturday, October 12, 2013 10:21:50 PM Seif Mazareeb wrote:
>> When CONFIG_NETLABEL is disabled, the cipso_v4_validate() function could
>> loop forever in the main loop if opt[opt_iter +1] == 0, this will causing a
>> kernel crash in an SMP system, since the CPU executing this function will
>> stall /not respond to IPIs.
>> 
>> This problem can be reproduced by running the IP Stack Integrity Checker
>> (http://isic.sourceforge.net) using the following command on a Linux machine
>> connected to DUT:
>> 
>> "icmpsic -s rand -d <DUT IP address> -r 123456"
>> wait (1-2 min)
>> 
>> Signed-off-by: Seif Mazareeb <seif@marvell.com>
> 
> Thanks for sticking with this.
> 
> Acked-by: Paul Moore <paul@paul-moore.com>

This patch, like all the others Seif submitted, has been corrupted by
his email client and is this unusable.
