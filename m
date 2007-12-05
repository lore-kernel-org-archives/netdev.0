From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] BRIDGE : br_fdb_fini() should be __exit_refok instead
 of __exit
Date: Wed, 05 Dec 2007 05:07:48 -0800 (PST)
Message-ID: <20071205.050748.187864113.davem@davemloft.net>
References: <47569C74.9020008@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48424
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751743AbXLENHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 08:07:49 -0500
In-Reply-To: <47569C74.9020008@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 05 Dec 2007 13:41:24 +0100

> Building last net-2.6.25 git tree gave me this warning :
> 
> WARNING: vmlinux.o(.init.text+0x2a957): Section mismatch: reference to 
> .exit.text:br_fdb_fini (between 'br_init' and 'br_fdb_init')
> 
> This is because br_init() (marked __init) can call br_fdb_fini() (marked __exit).
> 
> I am not sure the following is the right fix, since __exit_refok is quite new, 
> and seldom used.
> 
> [PATCH] BRIDGE : br_fdb_fini() should be __exit_refok instead of __exit
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

I have another patch like this from Andrew's -mm queue sitting
in my inbox, which I'll review and apply.

Thanks!
