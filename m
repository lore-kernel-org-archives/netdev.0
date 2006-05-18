From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Gianfar SKB Recycling Support
Date: Thu, 18 May 2006 12:11:44 +0200
Message-ID: <200605181211.45061.ak@suse.de>
References: <18AEF66AFDF06F4CAAA1D419D000FD33524B99@az33exm24.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Fleming Andy-afleming" <afleming@freescale.com>,
	"Kumar Gala" <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:18874 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1751306AbWERLMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 May 2006 07:12:48 -0400
To: "Haruki Dai-r35557" <Dai.Haruki@freescale.com>
In-Reply-To: <18AEF66AFDF06F4CAAA1D419D000FD33524B99@az33exm24.fsl.freescale.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>
> With grant of the description, it looks negative in the memory management,
> but actually, the amount of memory usage in the driver layer is less than
> the ordinaly gianfar (around half), especially the NAPI is enable. This
> recycling is introduced in order to chop down the critical path memory
> usage.

Explain? 

> Forwarding performance goes up 60 to 100% better, and amount of memory
> usage is half.

And what happens when the box doesn't route and isn't under full network
load? 

-Andi
