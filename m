From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/34] Pull request for
 'davem-next.base_addr.removal' branch
Date: Thu, 15 Mar 2012 15:05:26 -0700 (PDT)
Message-ID: <20120315.150526.353003174998399838.davem@davemloft.net>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59776 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755240Ab2COWGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 18:06:30 -0400
In-Reply-To: <cover.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 15 Mar 2012 14:56:57 +0100

> Please pull from branch 'davem-next.base_addr.removal' in repository
> 
> git://violet.fr.zoreil.com/romieu/linux davem-next.base_addr.removal
> 
> to get the changes below.

I don't think you can blindly override outl, readl, etc. with defines
without first properly undefining them.  Otherwise via indirect header
inclusion the asm/io.h definition will be present already and this
will result in compiler failures.

Frankly, I think you should just do it right, by overriding some
private macro for this purpose in such drivers and then do the
necessary sed 's/outl/foow32/' or whatever over the whole driver.

Please also address the other feedback you've received so far.

Thanks.
