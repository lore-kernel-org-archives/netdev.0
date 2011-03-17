From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCHv2 3/9] macb: unify at91 and avr32 platform data
Date: Thu, 17 Mar 2011 09:48:28 +0100
Message-ID: <871v26m8tf.fsf@macbook.be.48ers.dk>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
	<1300184096-13937-4-git-send-email-jamie@jamieiles.com>
	<87vczkmy94.fsf@macbook.be.48ers.dk>
	<AANLkTi=TiRnc0ceosH-P7fN7wKrLZE0MCJHQ30gM_Q9b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>, netdev@vger.kernel.org,
	plagnioj@jcrosoft.com, nicolas.ferre@atmel.com,
	linux-arm-kernel@lists.infradead.org
To: "avictor.za\@gmail.com" <avictor.za@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48434 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872Ab1CQIsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 04:48:45 -0400
Received: by wya21 with SMTP id 21so2525909wya.19
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 01:48:44 -0700 (PDT)
In-Reply-To: <AANLkTi=TiRnc0ceosH-P7fN7wKrLZE0MCJHQ30gM_Q9b@mail.gmail.com>
	(avictor's message of "Thu, 17 Mar 2011 10:43:09 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "avictor" == avictor za@gmail com <avictor.za@gmail.com> writes:

Hi,

 >> How about at the same time renaming it to something a bit less
 >> generic like macb_platform_data?

 avictor> The AT91RM9200 uses the same platform_data structure, but has a
 avictor> different Ethernet peripheral (ie, not the MACB)

 avictor> The phy_irq_pin is used in the AT91RM9200 ethernet driver.
 avictor> (drivers/net/arm/at91_ether.c)

That should probably be cleaned up as well then. Sharing platform_data
structures between unrelated drivers seems like quite a mess to me.

-- 
Bye, Peter Korsgaard
