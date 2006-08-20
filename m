From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] getsockopt() early argument sanity checking
Date: Sun, 20 Aug 2006 12:45:16 -0700 (PDT)
Message-ID: <20060820.124516.41639882.davem@davemloft.net>
References: <20060819230532.GA16442@openwall.com>
	<200608201034.43588.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: solar@openwall.com, wtarreau@hera.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:14298
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751179AbWHTTpG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 15:45:06 -0400
To: ak@suse.de
In-Reply-To: <200608201034.43588.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Sun, 20 Aug 2006 10:34:43 +0200

> Doing a check that is inherently racy everywhere doesn't seem like a
> security improvement to me. If there is really a length checking bug
> somewhere it needs to be fixed in a race-free way. If not then there
> is no need for a change.

Totally agreed, this change makes no sense on every level.
