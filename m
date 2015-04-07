From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: move inline functions to the header file
Date: Tue, 07 Apr 2015 15:22:49 -0400 (EDT)
Message-ID: <20150407.152249.360575010614186977.davem@davemloft.net>
References: <4254119.qJUdUQCUqs@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58821 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311AbbDGTWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 15:22:51 -0400
In-Reply-To: <4254119.qJUdUQCUqs@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Mon, 06 Apr 2015 00:13:46 +0300

> The explicitly inline functions belong to the header files, so move
> cpu_to_edmac() and edmac_to_cpu() into the driver header.
> 
> While at it, make these functions return 'u32' instead of '__u32'.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Then... ummm... remove the inline keyword?

If it's not used anywhere else, that's the thing to do.
