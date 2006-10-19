From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] Size listen hash tables using backlog hint
Date: Wed, 18 Oct 2006 22:08:37 -0700 (PDT)
Message-ID: <20061018.220837.74746240.davem@davemloft.net>
References: <200610171458.37636.dada1@cosmosbay.com>
	<20061018.203109.63997999.davem@davemloft.net>
	<453704F0.4010707@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:1931
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422800AbWJSFJX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Oct 2006 01:09:23 -0400
To: shemminger@osdl.org
In-Reply-To: <453704F0.4010707@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 18 Oct 2006 21:54:08 -0700

> Reminds me, anyone know why GCC is too stupid to convert modulus of a 
> constant power of 2 into a mask operation?

If the computation ends up being signed it can't perform this
optimization.
