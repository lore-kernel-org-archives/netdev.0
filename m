From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: cubic scaling error
Date: Wed, 25 Oct 2006 23:04:25 -0700 (PDT)
Message-ID: <20061025.230425.126576070.davem@davemloft.net>
References: <20061025105229.3b93aa17@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: doug.leith@nuim.ie, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:24746
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423422AbWJZGE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 02:04:29 -0400
To: shemminger@osdl.org
In-Reply-To: <20061025105229.3b93aa17@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 25 Oct 2006 10:52:29 -0700

> Doug Leith observed a discrepancy between the version of CUBIC described
> in the papers and the version in 2.6.18. A math error related to scaling
> causes Cubic to grow too slowly.
> 
> Patch is from "Sangtae Ha" <sha2@ncsu.edu>. I validated that
> it does fix the problems.
> 
> See the following to show behavior over 500ms 100 Mbit link.
> 
> Sender (2.6.19-rc3) ---  Bridge (2.6.18-rt7) ------- Receiver (2.6.19-rc3)
>                     1G      [netem]           100M
> 
> 	http://developer.osdl.org/shemminger/tcp/2.6.19-rc3/cubic-orig.png
> 	http://developer.osdl.org/shemminger/tcp/2.6.19-rc3/cubic-fix.png
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks a lot Stephen.
