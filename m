From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c59x: consolidate error cleanup in vortex_init_one()
Date: Wed, 12 Jun 2013 01:54:12 -0700 (PDT)
Message-ID: <20130612.015412.1184939775199846675.davem@davemloft.net>
References: <201306100016.52820.sergei.shtylyov@cogentembedded.com>
	<20130610115709.GA30712@slnx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org
To: klassert@mathematik.tu-chemnitz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51825 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753506Ab3FLIyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 04:54:15 -0400
In-Reply-To: <20130610115709.GA30712@slnx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Date: Mon, 10 Jun 2013 13:57:09 +0200

> On Mon, Jun 10, 2013 at 12:16:52AM +0400, Sergei Shtylyov wrote:
>> The PCI driver's probe() method  duplicates the error cleanup code each time it
>> has to do error exit. Consolidate the error cleanup code  in  one place and use
>> *goto* to jump to the right places.
>> 
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>> 
> 
> Looks ok,
> 
> Acked-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>

Applied, thanks.
