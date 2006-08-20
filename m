From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] getsockopt() early argument sanity checking
Date: Sun, 20 Aug 2006 12:46:05 -0700 (PDT)
Message-ID: <20060820.124605.71096208.davem@davemloft.net>
References: <20060819230532.GA16442@openwall.com>
	<200608201034.43588.ak@suse.de>
	<20060820101528.GE602@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, solar@openwall.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:16090
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751186AbWHTTpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 15:45:54 -0400
To: w@1wt.eu
In-Reply-To: <20060820101528.GE602@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Willy Tarreau <w@1wt.eu>
Date: Sun, 20 Aug 2006 12:15:28 +0200

> Others will consider it totally useless because it does not cover
> all cases, but I think it is against the general principle of
> precaution we try to apply in security.

Reading in a value from userspace twice for questionable
"security"  is just bogus.
