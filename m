From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: filter: Just In Time compiler
Date: Sun, 03 Apr 2011 22:07:45 -0700 (PDT)
Message-ID: <20110403.220745.173856758.davem@davemloft.net>
References: <1301783301.2837.77.camel@edumazet-laptop>
	<1301784797.3110.4.camel@localhost>
	<1301838968.2837.200.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@infradead.org,
	bhutchings@solarflare.com, hagen@jauu.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55496
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751878Ab1DDFIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 01:08:22 -0400
In-Reply-To: <1301838968.2837.200.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 03 Apr 2011 15:56:08 +0200

>  arch/x86/Kbuild              |    1 
>  arch/x86/Kconfig             |    1 
>  arch/x86/net/bpf_jit.S       |  142 +++++++
>  arch/x86/net/bpf_jit_comp.c  |  655 +++++++++++++++++++++++++++++++++

Is this missing arch/x86/net/Makefile?

Otherwise I can't see how the x86 bpf objects get built.
