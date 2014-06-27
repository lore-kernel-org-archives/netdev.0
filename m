From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] powerpc: bpf: Fix the broken
 LD_VLAN_TAG_PRESENT test
Date: Fri, 27 Jun 2014 16:14:40 -0700 (PDT)
Message-ID: <20140627.161440.1789637356563737660.davem@davemloft.net>
References: <1403717697-3911-1-git-send-email-kda@linux-powerpc.org>
	<1403717697-3911-2-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33652 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753242AbaF0XOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 19:14:41 -0400
In-Reply-To: <1403717697-3911-2-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <kda@linux-powerpc.org>
Date: Wed, 25 Jun 2014 21:34:57 +0400

> We have to return the boolean here if the tag presents
> or not, not just ANDing the TCI with the mask which results to:
> 
> [  709.412097] test_bpf: #18 LD_VLAN_TAG_PRESENT
> [  709.412245] ret 4096 != 1
> [  709.412332] ret 4096 != 1
> [  709.412333] FAIL (2 times)
> 
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>

Applied.
