From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [NET_SCHED 07/06]: Fix endless loops (part 5): netem/tbf/hfsc
 ->requeue failures
Date: Mon, 20 Nov 2006 10:08:51 -0800
Message-ID: <20061120100851.4a9f5573@freekitty>
References: <4561C32F.7000702@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:21132 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S934296AbWKTSJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 13:09:02 -0500
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4561C32F.7000702@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Nov 2006 16:01:03 +0100
Patrick McHardy <kaber@trash.net> wrote:

> I forgot to fix one (AFAICT purely theoretical) case ..
> 

So this means that if requeue fails we are no longer bolluxed.

-- 
Stephen Hemminger <shemminger@osdl.org>
