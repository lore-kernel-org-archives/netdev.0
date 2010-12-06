From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: am79c961a: Omit private ndo_get_stats function
Date: Mon, 06 Dec 2010 13:25:05 -0800 (PST)
Message-ID: <20101206.132505.39185516.davem@davemloft.net>
References: <1291310405-5759-1-git-send-email-tklauser@distanz.ch>
	<20101203154057.GC30898@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tklauser@distanz.ch, netdev@vger.kernel.org
To: linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40184
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753448Ab0LFVYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 16:24:39 -0500
In-Reply-To: <20101203154057.GC30898@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Fri, 3 Dec 2010 15:40:57 +0000

> On Thu, Dec 02, 2010 at 06:20:05PM +0100, Tobias Klauser wrote:
>> am79c961_getstats() just returns dev->stats so we can leave it out
>> alltogether and let dev_get_stats() do the job.
>> 
>> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> 
> Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>

Applied.
