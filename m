From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Kill arch_fast_hash
Date: Wed, 10 Dec 2014 23:37:48 -0500 (EST)
Message-ID: <20141210.233748.1555593565202478715.davem@davemloft.net>
References: <1418225592-29322-1-git-send-email-dborkman@redhat.com>
	<20141210.151838.1178381810877719493.davem@davemloft.net>
	<5488D3F5.8040701@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, hannes@stressinduktion.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50277 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750701AbaLKEhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 23:37:50 -0500
In-Reply-To: <5488D3F5.8040701@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 11 Dec 2014 00:15:01 +0100

> On 12/10/2014 09:18 PM, David Miller wrote:
> ...
>> Series applied, and I'll queue patch #1 to -stable, thanks.
> 
> Sounds good, thanks!
> 
> Btw, this will create a "silent" merge conflict with Linus' tree:
> As nios2 arch has been merged for 3.19, the 'generic-y += hash.h'
> from arch/nios2/include/asm/Kbuild needs to be removed there, too.

Thanks for letting me know.
