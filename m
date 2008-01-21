From: David Miller <davem@davemloft.net>
Subject: Re: [REGRESSION] 2.6.24-rc7: e1000: Detected Tx Unit Hang
Date: Mon, 21 Jan 2008 05:29:44 -0800 (PST)
Message-ID: <20080121.052944.82674046.davem@davemloft.net>
References: <18318.14810.877279.41815@robur.slu.se>
	<20080118.041144.81957249.davem@davemloft.net>
	<18324.40369.984595.651675@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: elendil@planet.nl, jesse.brandeburg@intel.com,
	slavon@bigtelecom.ru, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42391
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751850AbYAUN3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 08:29:38 -0500
In-Reply-To: <18324.40369.984595.651675@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Olsson <Robert.Olsson@data.slu.se>
Date: Mon, 21 Jan 2008 14:27:13 +0100

>  Yes it works. e1000 tested for ~3 hours with high very high load and 
>  interface up/down every 5:th sec. Without the patch the irq's gets 
>  disabled within a couple of seconds
> 
>  A resolute way of handling the semaphores. :)
>    
>  Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>


Thanks for testing Robert.

I sent off that fix to Linus an hour or so ago, hopefully
he will pick it up some time today.
