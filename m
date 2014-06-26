From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v2 2/2] powerpc: bpf: Fix the broken LD_VLAN_TAG_PRESENT
 test
Date: Thu, 26 Jun 2014 18:30:55 +1000
Message-ID: <1403771455.18572.8.camel@concordia>
References: <1403717697-3911-1-git-send-email-kda@linux-powerpc.org>
	 <1403717697-3911-2-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:43793 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750875AbaFZIa5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2014 04:30:57 -0400
In-Reply-To: <1403717697-3911-2-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-06-25 at 21:34 +0400, Denis Kirjanov wrote:
> We have to return the boolean here if the tag presents
> or not, not just ANDing the TCI with the mask which results to:
> 
> [  709.412097] test_bpf: #18 LD_VLAN_TAG_PRESENT
> [  709.412245] ret 4096 != 1
> [  709.412332] ret 4096 != 1
> [  709.412333] FAIL (2 times)

Hi Denis,

Is this the same version of test_bpf that is in Linus' tree?

I don't see any fails with that version, am I missing something?

  [  187.690640] test_bpf: #18 LD_VLAN_TAG_PRESENT 46 50 PASS

cheers
