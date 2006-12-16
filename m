From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [ANN] Acrypto asynchronous crypto layer 2.6.19 release.
Date: Sat, 16 Dec 2006 22:15:22 +0300
Message-ID: <20061216191521.GA26549@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:53194 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161382AbWLPTPa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Dec 2006 14:15:30 -0500
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

I am pleased to announce new release of the acrypto for 2.6.19 kernel -
first asynchronous crypto layer for Linux kernel 2.6.

Acrypto allows to handle crypto requests asynchronously in hardware.

Acrypto supports following features:
 * multiple asynchronous crypto device queues
 * crypto session routing (allows to complete single crypto session when
   several operations (crypto, hmac, anything) are completed)
 * crypto session binding (bind crypto processing to specified device)
 * modular load balancing (one can created load balancer which will get
   into account for example pid of the calling process)
 * crypto session batching genetically implemented by design (acrypto
   provides the whole data structure to crypto device, i.e. it is
   possible to use acrypto as a bridge which routes requests between
   completely different devices, since it does not differentiate between
   users, just handles requests)
 * crypto session priority
 * different kinds of crypto operation(RNG, asymmetrical crypto, HMAC and
   any other)

Combined patchset includes:
 * acrypto core
 * IPsec ESP4 port to acrypto
 * dm-crypt port to acrypto
 * OCF to acrypto bridge, which allows to run OCF device
   drivers with acrypto (for example ixp4xx), requires OCF installed.

Ported crypto drivers and benchmarks can be found on acrypto homepage:
http://tservice.net.ru/~s0mbre/old/?section=projects&item=acrypto

Changes from previous release:
 * moved to 2.6.19 crypto API where it is used
 * updated XFRM engine
 * bugfixes

2.6.16 - 2.6.18 releases moved to maintenance mode.

Patchset is not attached due to its size (192kb).

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

-- 
	Evgeniy Polyakov
