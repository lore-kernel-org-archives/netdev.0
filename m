From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3] xen/netfront: handle compound page fragments on
 transmit
Date: Wed, 21 Nov 2012 11:49:57 -0500 (EST)
Message-ID: <20121121.114957.441218567286373485.davem@davemloft.net>
References: <1353499336-28952-1-git-send-email-ian.campbell@citrix.com>
	<20121121151625.GA13127@konrad-lan.dumpdata.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, netdev@vger.kernel.org,
	xen-devel@lists.xen.org, edumazet@google.com, annie.li@oracle.com,
	linux@eikelenboom.it, stefan.bader@canonical.com
To: konrad@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755328Ab2KUQt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 11:49:59 -0500
In-Reply-To: <20121121151625.GA13127@konrad-lan.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Date: Wed, 21 Nov 2012 10:16:27 -0500

> On Wed, Nov 21, 2012 at 12:02:16PM +0000, Ian Campbell wrote:
>> An SKB paged fragment can consist of a compound page with order > 0.
>> However the netchannel protocol deals only in PAGE_SIZE frames.
>> 
>> Handle this in xennet_make_frags by iterating over the frames which
>> make up the page.
>> 
>> This is the netfront equivalent to 6a8ed462f16b for netback.
>> 
>> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
>> Cc: netdev@vger.kernel.org
>> Cc: xen-devel@lists.xen.org
>> Cc: Eric Dumazet <edumazet@google.com>
>> Cc: Konrad Rzeszutek Wilk <konrad@kernel.org>
> 
> Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> 
> David, would you like me to send it to Linus via my tree or are you
> OK sending him a git pull with this patch (and hopefully some other
> ones?)

I'll merge this to Linus via my net tree, thanks.
