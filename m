From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCHv2 3/9] macb: unify at91 and avr32 platform data
Date: Thu, 17 Mar 2011 10:22:53 +0100
Message-ID: <87wrjyksnm.fsf@macbook.be.48ers.dk>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
	<1300184096-13937-4-git-send-email-jamie@jamieiles.com>
	<87vczkmy94.fsf@macbook.be.48ers.dk>
	<AANLkTi=TiRnc0ceosH-P7fN7wKrLZE0MCJHQ30gM_Q9b@mail.gmail.com>
	<871v26m8tf.fsf@macbook.be.48ers.dk>
	<20110317085835.GC29758@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "avictor.za\@gmail.com" <avictor.za@gmail.com>,
	Jamie Iles <jamie@jamieiles.com>, plagnioj@jcrosoft.com,
	linux-arm-kernel@lists.infradead.org, nicolas.ferre@atmel.com,
	netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55732 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752890Ab1CQJXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 05:23:38 -0400
Received: by wwa36 with SMTP id 36so3263096wwa.1
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 02:23:36 -0700 (PDT)
In-Reply-To: <20110317085835.GC29758@n2100.arm.linux.org.uk> (Russell King's
	message of "Thu, 17 Mar 2011 08:58:35 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Russell" == Russell King <- ARM Linux <linux@arm.linux.org.uk>> writes:

Hi,

 >> That should probably be cleaned up as well then. Sharing platform_data
 >> structures between unrelated drivers seems like quite a mess to me.

 Russell> Why should every driver have a separate platform data structure?
 Russell> Is it right to end up with thousands of unique data structures each
 Russell> specific to a particular driver?  To me, that sounds like a headache
 Russell> waiting to happen.

Well, the point of the platform data is to provide driver specific
(E.G. not generic) data to the driver, so in general it will be
different for different hardware.

The current situation with 2 different structure defination depending on
arch, macro magic and 1 of these structures also used for a 2nd driver
isn't optimal.

But ok, I don't feel strongly about struct macb_platform_data also being
used for the old at91_ether driver, but it shouldn't be called
eth_platform_data as it isn't really a generic structure.

-- 
Bye, Peter Korsgaard
