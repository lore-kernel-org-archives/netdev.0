From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] tcp: set default congestion control when no sysctl
Date: Tue, 31 Oct 2006 17:31:47 -0800 (PST)
Message-ID: <20061031.173147.115639064.davem@davemloft.net>
References: <20061031230140.191929094@osdl.org>
	<20061031230213.529807216@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37773
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423639AbWKABbq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Oct 2006 20:31:46 -0500
To: shemminger@osdl.org
In-Reply-To: <20061031230213.529807216@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 31 Oct 2006 15:01:41 -0800

> The setting of the default congestion control was buried in
> the sysctl code so it would not be done properly if SYSCTL was
> not enabled.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Good catch, applied for 2.6.19, thanks Stephen.
