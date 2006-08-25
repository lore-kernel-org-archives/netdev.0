From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPV6 : segmentation offload not set correctly on TCP
 children
Date: Fri, 25 Aug 2006 15:56:02 -0700 (PDT)
Message-ID: <20060825.155602.132757635.davem@davemloft.net>
References: <20060821150231.31a947d4@localhost.localdomain>
	<20060821222634.GC21790@cip.informatik.uni-erlangen.de>
	<20060825154353.3ecaf508@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sithglan@stud.uni-erlangen.de, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:23723
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964771AbWHYWz5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 18:55:57 -0400
To: shemminger@osdl.org
In-Reply-To: <20060825154353.3ecaf508@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 25 Aug 2006 15:43:53 -0700

> TCP over IPV6 would incorrectly inherit the GSO settings.
> This would cause kernel to send Tcp Segmentation Offload packets for
> IPV6 data to devices that can't handle it. It caused the sky2 driver
> to lock http://bugzilla.kernel.org/show_bug.cgi?id=7050
> and the e1000 would generate bogus packets. I can't blame the
> hardware for gagging if the upper layers feed it garbage.
> 
> This was a new bug in 2.6.18 introduced with GSO support.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Good catch.  Applied, thanks Stephen.
