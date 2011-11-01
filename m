From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] drivers/net/ethernet/i825xx/3c505.c: fix build
 with dynamic debug
Date: Tue, 01 Nov 2011 00:54:17 -0400 (EDT)
Message-ID: <20111101.005417.2095801593051798581.davem@davemloft.net>
References: <201110311954.p9VJs9VO002313@hpaq3.eem.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@google.com, jbaron@redhat.com,
	philb@gnu.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47889 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702Ab1KAEy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 00:54:27 -0400
In-Reply-To: <201110311954.p9VJs9VO002313@hpaq3.eem.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 31 Oct 2011 12:54:09 -0700

> From: Andrew Morton <akpm@google.com>
> Subject: drivers/net/ethernet/i825xx/3c505.c: fix build with dynamic debug
> 
> The `#define filename' screws up the expansion of
> DEFINE_DYNAMIC_DEBUG_METADATA:
> 
> drivers/net/ethernet/i825xx/3c505.c: In function 'send_pcb':
> drivers/net/ethernet/i825xx/3c505.c:390: error: expected identifier before string constant
> drivers/net/ethernet/i825xx/3c505.c:390: error: expected '}' before '.' token
> drivers/net/ethernet/i825xx/3c505.c:436: error: expected identifier before string constant
> drivers/net/ethernet/i825xx/3c505.c:435: error: expected '}' before '.' token
> drivers/net/ethernet/i825xx/3c505.c: In function 'start_receive':
> drivers/net/ethernet/i825xx/3c505.c:557: error: expected identifier before string constant
> drivers/net/ethernet/i825xx/3c505.c:557: error: expected '}' before '.' token
> drivers/net/ethernet/i825xx/3c505.c: In function 'receive_packet':
> drivers/net/ethernet/i825xx/3c505.c:629: error: expected identifier before string constant
> 
> etc
> 
> So remove that #define and "open-code" it.
> 
> Cc: Philip Blundell <philb@gnu.org>
> Cc: David Miller <davem@davemloft.net>
> Cc: Jason Baron <jbaron@redhat.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
