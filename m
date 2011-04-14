From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ip: ip_options_compile() resilient to NULL skb route
Date: Thu, 14 Apr 2011 15:04:57 -0700 (PDT)
Message-ID: <20110414.150457.112598807.davem@davemloft.net>
References: <20110414123058.d4ffe7fb.shimoda.hiroaki@gmail.com>
	<1302796537.3248.22.camel@edumazet-laptop>
	<4DA76F08.5000302@scotdoyle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, shimoda.hiroaki@gmail.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: lkml@scotdoyle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38984
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752901Ab1DNWFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 18:05:32 -0400
In-Reply-To: <4DA76F08.5000302@scotdoyle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scot Doyle <lkml@scotdoyle.com>
Date: Thu, 14 Apr 2011 17:02:48 -0500

> The 2.6.39-rc3 kernel, plus this patch and the two patches previously
> accepted by David in this thread, didn't panic when tested with the IP
> Stack Checker tool hitting either the assigned bridge IP address or a
> guest virtual machine IP address sharing that bridge.

Thank you for testing.
