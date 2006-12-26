From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] netpoll: drivers must not enable IRQ unconditionally
 in their NAPI handler
Date: Tue, 26 Dec 2006 16:24:21 -0500
Message-ID: <45919305.90603@garzik.org>
References: <20061217220315.GA26485@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	Gary Zambrano <zambrano@broadcom.com>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41380 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932791AbWLZVYY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Dec 2006 16:24:24 -0500
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20061217220315.GA26485@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> net/core/netpoll.c::netpoll_send_skb() calls the poll handler when
> it is available. As netconsole can be used from almost any context,
> IRQ must not be enabled blindly in the NAPI handler of a driver which
> supports netpoll.
> 
> b57bd06655a028aba7b92e1c19c2093e7fcfb341 fixed the issue for the
> 8139too.c driver.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

applied


