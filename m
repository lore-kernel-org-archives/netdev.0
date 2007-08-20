From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] spidernet: fix interrupt reason recognition
Date: Mon, 20 Aug 2007 17:38:19 -0500
Message-ID: <20070820223819.GK4261@austin.ibm.com>
References: <20070820.221327.-1300518791.kouish@swc.toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org,
	Arnd Bergmann <arnd@arndb.de>
To: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:54917 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751468AbXHTWiV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2007 18:38:21 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7KMcLeK031173
	for <netdev@vger.kernel.org>; Mon, 20 Aug 2007 18:38:21 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7KMcK5G527602
	for <netdev@vger.kernel.org>; Mon, 20 Aug 2007 18:38:21 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7KMcKit024181
	for <netdev@vger.kernel.org>; Mon, 20 Aug 2007 18:38:20 -0400
Content-Disposition: inline
In-Reply-To: <20070820.221327.-1300518791.kouish@swc.toshiba.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 20, 2007 at 10:13:27PM +0900, Ishizaki Kou wrote:
> Please apply this to 2.6.23.

I'll review and forward shortly.  Kick me if you don't see a formal
reply in a few days.

> And also, please apply the following Arnd-san's patch to fix a problem
> that spidernet driver sometimes causes a BUG_ON at open.
> 
>  http://patchwork.ozlabs.org/cbe-oss-dev/patch?id=12211

Are you sure? This patch no longer applies cleanly, in part because
your patch "[PATCH] spidernet: improve interrupt handling" 
from Mon, 09 Jul 2007 added a spider_net_enable_interrupts(card); 
at the end of spider_net_open().  Because of this, it seems like 
Arnd's patch is no longer needed, right?

--linas
