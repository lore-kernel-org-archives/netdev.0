From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] Removal of FASTROUTE definition
 include/linux/if_packet.h
Date: Thu, 02 Aug 2007 02:26:37 -0700 (PDT)
Message-ID: <20070802.022637.10299486.davem@davemloft.net>
References: <eb3ff54b0708020223o521e89b9v3200e06ab296df12@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35632
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752017AbXHBJ0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2007 05:26:36 -0400
In-Reply-To: <eb3ff54b0708020223o521e89b9v3200e06ab296df12@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Rami Rosen" <ramirose@gmail.com>
Date: Thu, 2 Aug 2007 12:23:41 +0300

> Hi,
>   It seems that PACKET_FASTROUTE definition should be removed due to that
> 	fastroute is no longer supported.

It's a value exported to userland, so removing it could
break application compilation, so we can't remove it.
