From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: doubt about qla3xxx checksum "fix"
Date: Sun, 3 Jun 2007 18:50:59 -0700
Message-ID: <20070603185059.7f1e76cd@freepuppy>
References: <20070603.180051.89019554.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58892 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750892AbXFDCCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jun 2007 22:02:46 -0400
In-Reply-To: <20070603.180051.89019554.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 03 Jun 2007 18:00:51 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> 
> I don't think it's %100 right, I'm referring specifically to
> 
> e68a8c10c4c5daf363e946d10c1a5cba77d7f92c
> 
> Sure, qla3xxx is only handling ipv4 in that ql_hw_csum_setup()
> function, but if you check the call site it really wants
> CHECKSUM_PARTIAL skb's to work on.  And CHECKSUM_PARTIAL skbs are only
> setup for paths that advertise the NETIF_F_HW_CSUM capability.

CHECKSUM_PARTIAL is used on xmit for both NETIF_F_HWCSUM and NETIF_F_IPCSUM 
See acenic, 3c59x, ...


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
