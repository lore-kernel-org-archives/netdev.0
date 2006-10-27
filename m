From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4 of 9] NetEffect 10Gb RNIC Driver: kernel driver
 header files
Date: Thu, 26 Oct 2006 17:16:57 -0700 (PDT)
Message-ID: <20061026.171657.43852974.davem@davemloft.net>
References: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9EBD@venom2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: openib-general@openib.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:53946
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1946049AbWJ0ARV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 20:17:21 -0400
To: ggrundstrom@NetEffect.com
In-Reply-To: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9EBD@venom2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Glenn Grundstrom" <ggrundstrom@NetEffect.com>
Date: Thu, 26 Oct 2006 19:14:19 -0500

> It is part of our connection manager and assists with connection setup
> and teardown only.

I fear this is exactly the kind of stuff that we didn't want
to see start going into the kernel, and we've resisted the
TCP/IP stack offload stuff in the infiniband layer exactly
for this reason.
