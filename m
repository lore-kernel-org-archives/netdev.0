From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp.c: calculate tcp_mem based on low memory instead
 of all memory
Date: Fri, 27 Jun 2008 17:24:16 -0700 (PDT)
Message-ID: <20080627.172416.106612371.davem@davemloft.net>
References: <20080618153042.GA27663@xs4all.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: miquels@cistron.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50209
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752817AbYF1AYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 20:24:16 -0400
In-Reply-To: <20080618153042.GA27663@xs4all.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Miquel van Smoorenburg <miquels@cistron.nl>
Date: Wed, 18 Jun 2008 17:30:45 +0200

> [PATCH] tcp.c: calculate tcp_mem based on low memory instead of all memory
> 
> The tcp_mem array which contains limits on the total amount of
> memory used by TCP sockets is calculated based on nr_all_pages.
> On a 32 bits x86 system, we should base this on the number of
> lowmem pages.
> 
> Signed-off-by: Miquel van Smoorenburg <miquels@cistron.nl>

Patch applied, thanks Miquel.
