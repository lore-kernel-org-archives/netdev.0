From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] Update jhash.h with the new version of Jenkins' hash
Date: Thu, 12 Feb 2009 01:41:26 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0902120141040.23714@fbirervta.pbzchgretzou.qr>
References: <alpine.DEB.2.00.0902111107480.15665@blackhole.kfki.hu> <20090212001223.GA5757@movementarian.org> <20090211.162928.193706021.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: wli@movementarian.org, kadlec@blackhole.kfki.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:55098 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160AbZBLAl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 19:41:28 -0500
In-Reply-To: <20090211.162928.193706021.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 2009-02-12 01:29, David Miller wrote:
>
>> (double)0xdeadbeef/((unsigned long long)1 << 32) is a rather poor
>> approximation of (sqrt(5)-1)/2. If this value which is not the
>> golden ratio is arbitrary, calling it something different from
>> JHASH_GOLDEN_RATIO would surprise the code's readers much less.
>
>Then we can change the name, whatever...
>
>But really, anyone truly interested will read the friggin' web site
>where all the design documents and hash test results live.

Why should we use deadbeef over golden_ratio anyway? It's just a
random constant. And I'd take the gold over beef anytime ;-)
