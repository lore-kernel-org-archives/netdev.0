From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 2/2]: net/ipv{4,6}: reduce code size by inlining
Date: Tue, 14 Nov 2006 20:20:21 -0800 (PST)
Message-ID: <20061114.202021.23014512.davem@davemloft.net>
References: <200611140849.18324@strip-the-willow>
	<200611141327.22170.ak@suse.de>
	<200611141250.33918@strip-the-willow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20960
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S966571AbWKOEUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Nov 2006 23:20:20 -0500
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <200611141250.33918@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 14 Nov 2006 12:50:33 +0000

> Quoting Andi Kleen:
> |  On Tuesday 14 November 2006 09:49, Gerrit Renker wrote:
> |  > [UDP]: Reduce size of shared code
> |  > 
> |  > This patch reduces size of source code files by moving
> |  > some of the smaller functions shared by UDP and UDP-Lite
> |  > into the header file udp_impl.h, and in-lining these.
> |  > 
> |  > It is an optimisation and applies on top of the previous
> |  > UDP-Lite patch.
> |  
> |  Wouldn't it be better to just call them? They all don't 
> |  particularly time critical.
> This patch was sent as an optional add-on, it is not as important
> as the other one. You are probably right - I also noted that the
> gains (in terms of line numbers) are not as high as intended.

I'm not too sure on this one either, so I won't apply this one
for now.
