From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: only modify checksum for UDP
Date: Fri, 10 Nov 2006 14:55:07 -0800 (PST)
Message-ID: <20061110.145507.112290147.davem@davemloft.net>
References: <45536622.90708@hp.com>
	<20061109.151402.15590179.davem@davemloft.net>
	<4554A7CD.6040907@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ftp.linux.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:40350
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1946748AbWKJWzF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 17:55:05 -0500
To: brian.haley@hp.com
In-Reply-To: <4554A7CD.6040907@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Brian Haley <brian.haley@hp.com>
Date: Fri, 10 Nov 2006 11:24:45 -0500

> Only change upper-layer checksum from 0 to 0xFFFF for UDP (as RFC 768 
> states), not for others as RFC 4443 doesn't require it.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Applied, thanks Brian.
