From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: bugreport: The r8169.c driver is calling netif_receive_skb from
 hardirq and with interrupts off
Date: Tue, 15 Apr 2008 09:34:38 -0700
Message-ID: <4804D91E.30106@linux.intel.com>
References: <48039BEC.7070008@linux.intel.com>	<20080414112210.3c7ab1bb@extreme>	<4803A144.3030300@linux.intel.com> <20080414113151.7c860830@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	NetDev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:34967 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754937AbYDOQen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 12:34:43 -0400
In-Reply-To: <20080414113151.7c860830@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> *** But we are both wrong ***
> This is not the mainline r8169 driver but more likely the out of tree 
> vendor 8168 driver. There is no rtl8168_rx_interrupt in mainline.

woops...
sorry about that
