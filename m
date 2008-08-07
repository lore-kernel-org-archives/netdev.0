From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen multiqueue etc
Date: Thu, 07 Aug 2008 02:23:24 -0700 (PDT)
Message-ID: <20080807.022324.219303433.davem@davemloft.net>
References: <18584.25487.497437.392345@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: robert@robur.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37809
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755841AbYHGMaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 08:30:04 -0400
In-Reply-To: <18584.25487.497437.392345@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Olsson <robert@robur.slu.se>
Date: Tue, 5 Aug 2008 16:28:31 +0200

> Sofar far pktgen have had a restriction to only use one device per kernel 
> thread. With the new multiqueue architecture this is no longer adequate.
> 
> The patch below is an effort to remove this by in pktgen configuration 
> adding a tag to  the device name a la eth0@0 etc. The tag is used for 
> usual device config just as before. Also a new flag is introduced to mirror 
> queue_map with sending threads smp_processor_id() QUEUE_MAP_CPU.
 ...
> Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

Applied.
