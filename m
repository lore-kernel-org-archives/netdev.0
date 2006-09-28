From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [ACRYPTO] New asynchronous crypto layer (acrypto) release.
Date: Thu, 28 Sep 2006 16:08:26 +0400
Message-ID: <20060928120826.GA18063@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:27089 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751867AbWI1MI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 08:08:27 -0400
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

I'm pleased to announce asynchronous crypto layer (acrypto) [1] release 
for 2.6.18 kernel tree. Acrypto allows to handle crypto requests 
asynchronously in hardware.

Combined patchset includes:
 * acrypto core
 * IPsec ESP4 port to acrypto
 * dm-crypt port to acrypto
 * OCF to acrypto bridge

Acrypto supports following crypto providers:
 * SW crypto provider
 * HIFN 795x adapters
 * VIA nehemiah CPU
 * SuperCrypt CE99C003B
 * devices supported by OCF

With this release of combined patchset for 2.6.18 I drop feature
extensions for 2.6.16 and 2.6.17 trees and move them into maintenance
state.

Combined patchset [190k] and drivers for various acrypto providers can 
be found on project's homepage.

1. Acrypto homepage.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=acrypto

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

-- 
	Evgeniy Polyakov


-- 
	Evgeniy Polyakov
