From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] getsockopt() early argument sanity checking
Date: Sun, 20 Aug 2006 12:47:51 -0700 (PDT)
Message-ID: <20060820.124751.104041574.davem@davemloft.net>
References: <200608201034.43588.ak@suse.de>
	<20060820161602.GA20163@openwall.com>
	<1156091451.23756.51.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: solar@openwall.com, ak@suse.de, wtarreau@hera.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:17370
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751183AbWHTTrl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 15:47:41 -0400
To: arjan@infradead.org
In-Reply-To: <1156091451.23756.51.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arjan van de Ven <arjan@infradead.org>
Date: Sun, 20 Aug 2006 18:30:51 +0200

> this reasoning goes out the window with kernel preemption of course ;)

Yes and even though this thing is for 2.4.x, it just shows
that this is a hack and we shouldn't eat two userspace
accesses for a hack.

Instead fix the setsockopt() implementations that aren't
checking the optlen parameter correctly.
