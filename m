From: Adrian Bunk <bunk@stusta.de>
Subject: RFC: removing DONGLE_OLD drivers?
Date: Mon, 9 Jul 2007 19:25:39 +0200
Message-ID: <20070709172539.GF3492@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:55750 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753868AbXGIRZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 13:25:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With one exception, all DONGLE_OLD drivers have newer counterparts.

The DONGLE_OLD drivers depend on BROKEN_ON_SMP which e.g. implies that 
the many distributions shipping only SMP-kernels will never offer them.

The one exception is a driver for the Cirrus Logic EDB-7211 evaluation 
board that itself is out of production for some years.

Can we remove these old drivers or is there a good reason for keeping 
them?

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

