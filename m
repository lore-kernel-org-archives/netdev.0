From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] declance: Remove `incompatible pointer type'
 warnings
Date: Sat, 28 Sep 2013 15:33:16 -0700 (PDT)
Message-ID: <20130928.153316.1766304011894422920.davem@davemloft.net>
References: <alpine.LFD.2.03.1309200008060.5967@linux-mips.org>
	<20130920.144304.2081229489870626586.davem@davemloft.net>
	<alpine.LFD.2.03.1309222113300.16797@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org
To: macro@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33888 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755084Ab3I1W0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 18:26:17 -0400
In-Reply-To: <alpine.LFD.2.03.1309222113300.16797@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Sun, 22 Sep 2013 21:19:01 +0100 (BST)

> Revert damage caused by 43d620c82985b19008d87a437b4cf83f356264f7 
> [drivers/net: Remove casts of void *]:
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
> ---
>> Applied to net-next
> 
>  Thanks, by Sergei's request please use this version instead that has the 
> reference to the original commit updated (no change to the patch itself).

I can't undo the original commit once it has been installed in my tree.
