From: stephen mulcahy <smulcahy@gmail.com>
Subject: Re: [PATCH] forcedeth: fix tx limit2 flag check
Date: Wed, 14 Apr 2010 11:14:56 +0100
Message-ID: <4BC595A0.6040409@gmail.com>
References: <1271160298.2098.0.camel@achroite.uk.solarflarecom.com>	<4BC47F38.5040509@gmail.com>	<1271169741.16881.437.camel@edumazet-laptop> <20100413.144340.138717714.davem@davemloft.net> <4BC5532E.7000302@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"572201@bugs.debian.org" <572201@bugs.debian.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep20-int.chello.at ([62.179.121.40]:31216 "EHLO
	viefep20-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754216Ab0DNKPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 06:15:07 -0400
In-Reply-To: <4BC5532E.7000302@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ayaz Abdulla wrote:
> This patch fixes the TX_LIMIT feature flag. The previous logic check for 
> TX_LIMIT2 also took into account a device that only had TX_LIMIT set.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
> 
> This is a fix for bug 572201 @ bugs.debian.org

Hi,

Thanks! I'll rebuild my Debian kernel with this and run a test today.

-stephen
