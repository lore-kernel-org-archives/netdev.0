From: Ingo Molnar <mingo@elte.hu>
Subject: [build bug] drivers/net/netxen/netxen_nic_main.c:1189: error:
	implicit declaration of function 'ipv6_hdr'
Date: Fri, 16 Jan 2009 11:32:09 +0100
Message-ID: <20090116103209.GA9122@elte.hu>
References: <20090115.160159.262623707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Dhananjay Phadke <dhananjay@netxen.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:42382 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757462AbZAPKdD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jan 2009 05:33:03 -0500
Content-Disposition: inline
In-Reply-To: <20090115.160159.262623707.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Miller <davem@davemloft.net> wrote:

>       netxen: fix endianness in firmware commands
>       netxen: fix ipv6 offload and tx cleanup
>       netxen: fix link speed reporting for some boards
>       netxen: firmware init fix
>       netxen: cleanup mac list on driver unload
>       netxen: hold tx lock while sending firmware commands
>       netxen: handle dma mapping failures

One of these causes frequent build failures on x86, on today's -git:

 drivers/net/netxen/netxen_nic_main.c:1189: error: implicit declaration of function 'ipv6_hdr'
 drivers/net/netxen/netxen_nic_main.c:1189: error: invalid type argument of '->'

i suspect the key aspect is:

# CONFIG_IPV6 is not set

	Ingo
