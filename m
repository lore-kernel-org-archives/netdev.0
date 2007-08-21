From: "Reither Robert" <Robert.Reither@av-digital.at>
Subject: still not properly working multicast receiving at rtk8110SC (with 23rc3+ your patches)
Date: Tue, 21 Aug 2007 11:10:10 +0200
Message-ID: <BA41E8A07B73A041948C2E3A4EF6239D062E16@av-digital-exch.avdigital.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av-digital.at ([213.33.59.122]:27762 "EHLO
	av-digital-exch.avdigital.at" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752163AbXHUJKU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2007 05:10:20 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Francois,

i just tested the new kernel 2.6.23rc3 with and without your patches, i cannot find a difference to the behaviour of the previous state ... (22 + your patches)

I still have a very unreliable receiving of multicast packets, only for about 1/3 of my join mc attempts or so i receive them, in the other cases i do not.

Glen Gray also reported the same problems here on list, and i did some conversation.
I'm using a Jetway mini-ITX board 7F4K with VIA C7 processor and he uses a similar platform, also with a C7 cpu, maybe the platform influences the problem ?
Do we have reports on other platforms with the r8110SC and multicast receiving ?

I also tried drivers from realtek homepage (the new 2.x series does not compile under kernel >2.6.20)
The older driver (1.x for kernel 2.4) does work fine for me if i do some changes to the code to fit with kernel 2.6 series (transfered code from older versions which did support 2.6 too).

Greetings
Robert
