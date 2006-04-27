From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Wed, 26 Apr 2006 23:08:12 -0700 (PDT)
Message-ID: <20060426.230812.13989689.davem@davemloft.net>
References: <54AD0F12E08D1541B826BE97C98F99F143AEE0@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, kelly@au1.ibm.com, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:6294
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964946AbWD0GIi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 02:08:38 -0400
To: caitlinb@broadcom.com
In-Reply-To: <54AD0F12E08D1541B826BE97C98F99F143AEE0@NT-SJCA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Caitlin Bestler" <caitlinb@broadcom.com>
Date: Wed, 26 Apr 2006 18:02:43 -0700

> Would it be reasonable to state that a net channel carrying
> SYNs should not be set up when the consumer is a user mode
> process?

I'm currently assuming that the protocol processing is still done in
the kernel on behalf of the user context, so the issues you raise
really aren't relevant.

We really shouldn't be jumping the gun so far into the implementation
as others seem to be doing.  Let's do it simple first and see if
putting things all the way to userspace even is necessary.

No work is going to get done if we keep carrying on like this
over details we really do not need to consider right away.
