From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] ovs: introduce arch-specific fast
 hashing improvements
Date: Thu, 12 Dec 2013 16:12:41 -0500 (EST)
Message-ID: <20131212.161241.862399141932943486.davem@davemloft.net>
References: <1386860946-1621-1-git-send-email-ffusco@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, netdev@vger.kernel.org, dev@openvswitch.org,
	dborkman@redhat.com
To: ffusco@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39797 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526Ab3LLVMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 16:12:47 -0500
In-Reply-To: <1386860946-1621-1-git-send-email-ffusco@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francesco Fusco <ffusco@redhat.com>
Date: Thu, 12 Dec 2013 16:09:04 +0100

> We are introducing a fast hash function (see patch1) that can be
> used in the context of OpenVSwitch to reduce the hashing footprint
> (patch2). For details, please see individual patches!

No objections from my side, I'll let the x86 folks get a chance to
review this.  I can add this optimization on sparc64 chips that have
the crc instructions too.

I think we'll need to add implementations hash_3words, hash_2words,
and hash_1word when we try to take advantage of this in the networking
more generally.
