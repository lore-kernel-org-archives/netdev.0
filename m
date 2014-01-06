From: David Miller <davem@davemloft.net>
Subject: Re: tx-nocache-copy performance
Date: Mon, 06 Jan 2014 16:20:24 -0500 (EST)
Message-ID: <20140106.162024.1656283406092977289.davem@davemloft.net>
References: <20140106202754.GA5877@d2.synalogic.ca>
	<CA+mtBx_RH3v92Pmd_TYM=i0Anx-iG63762NPRSeCc1k98-Q6UQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bpoirier@suse.de, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34751 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755702AbaAFVU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 16:20:26 -0500
In-Reply-To: <CA+mtBx_RH3v92Pmd_TYM=i0Anx-iG63762NPRSeCc1k98-Q6UQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 6 Jan 2014 12:59:59 -0800

> btw, I still believe it would be a win if we could use vmsplice to
> mitigate the copy altogether, unfortunately no one has yet to come up
> with an interface to reliably reclaim buffers :-(.

Indeed, this issue keeps coming up continually.
