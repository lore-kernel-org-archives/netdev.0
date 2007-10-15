From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET] TC35815: Fix build
Date: Mon, 15 Oct 2007 14:33:54 -0400
Message-ID: <4713B292.6060708@garzik.org>
References: <20071014134026.GA30056@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Atsushi Nemoto <anemo@mba.ocn.ne.jp>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53601 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933885AbXJOSd6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 14:33:58 -0400
In-Reply-To: <20071014134026.GA30056@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ralf Baechle wrote:
> bea3348eef27e6044b6161fd04c3152215f96411 broke the build of tc35815.c
> for the non-NAPI case:
> 
>   CC      drivers/net/tc35815.o
> drivers/net/tc35815.c: In function 'tc35815_interrupt':
> drivers/net/tc35815.c:1464: error: redefinition of 'lp'
> drivers/net/tc35815.c:1443: error: previous definition of 'lp' was here
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

applied


