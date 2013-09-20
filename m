From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] declance: Remove `incompatible pointer type' warnings
Date: Fri, 20 Sep 2013 14:43:04 -0400 (EDT)
Message-ID: <20130920.144304.2081229489870626586.davem@davemloft.net>
References: <alpine.LFD.2.03.1309200008060.5967@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: macro@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39347 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753639Ab3ITSnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 14:43:05 -0400
In-Reply-To: <alpine.LFD.2.03.1309200008060.5967@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Fri, 20 Sep 2013 00:49:44 +0100 (BST)

> Revert damage caused by 43d620c82985b19008d87a437b4cf83f356264f7:
> 
> .../declance.c: In function 'cp_to_buf':
> .../declance.c:347: warning: assignment from incompatible pointer type
> .../declance.c:348: warning: assignment from incompatible pointer type
> .../declance.c: In function 'cp_from_buf':
> .../declance.c:406: warning: assignment from incompatible pointer type
> .../declance.c:407: warning: assignment from incompatible pointer type
> 
> Also add a `const' qualifier where applicable and adjust formatting.
> 
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>

Applied to net-next
