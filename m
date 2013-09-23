From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/12] tcp.h: Remove extern from function prototypes
Date: Mon, 23 Sep 2013 16:45:25 -0400 (EDT)
Message-ID: <20130923.164525.579641853180559261.davem@davemloft.net>
References: <445209f8885ccd8234fa787c30d63e63fc7917d7.1379961014.git.joe@perches.com>
	<20130923.163010.976299939444640897.davem@davemloft.net>
	<1379969042.3575.65.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43436 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753711Ab3IWUp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 16:45:27 -0400
In-Reply-To: <1379969042.3575.65.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 23 Sep 2013 13:44:02 -0700

> On Mon, 2013-09-23 at 16:30 -0400, David Miller wrote:
>> Series applied,
> 
> How about the same changes for the .h files in drivers/net ?
> 
> (slowly of course, and by maintained subsystem)
> 
> $ git grep -E "^\s*\bextern(\s+\w+){1,4}\s*\(\s*[^\*]" drivers/net/ | wc -l
> 1445
> 
> Maybe something like groups of:
> $ git grep -E --name-only "^\s*\bextern(\s+\w+){1,4}\s*\(\s*[^\*]" drivers/net/  | \
> 	cut -f3- -d"/" | cut -f1,2 -d"/" | uniq | \
> 	while read file ; do if [ -d drivers/net/$file ] ; then echo $file ; fi ; done

Sure.
