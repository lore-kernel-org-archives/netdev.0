From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ibm_newemac: Fix new MAL feature handling
Date: Tue, 21 Oct 2008 01:17:36 -0400
Message-ID: <48FD65F0.9070000@pobox.com>
References: <20081015213337.a99a9595.akpm@linux-foundation.org> <1224133010.8157.543.camel@pasglop> <20081016143840.GA29805@yoda.jdub.homelinux.org> <1224546221.7654.196.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Josh Boyer <jwboyer@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53390 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751032AbYJUFSK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 01:18:10 -0400
In-Reply-To: <1224546221.7654.196.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Herrenschmidt wrote:
> On Thu, 2008-10-16 at 10:38 -0400, Josh Boyer wrote:
>> On Thu, Oct 16, 2008 at 03:56:50PM +1100, Benjamin Herrenschmidt wrote:
>>>> drivers/net/ibm_newemac/mal.c: In function 'mal_txeob':
>>>> drivers/net/ibm_newemac/mal.c:284: error: implicit declaration of function 'mtdcri'
>>>> drivers/net/ibm_newemac/mal.c:284: error: 'SDR0' undeclared (first use in this function)
>>>> drivers/net/ibm_newemac/mal.c:284: error: (Each undeclared identifier is reported only once
>>>> drivers/net/ibm_newemac/mal.c:284: error: for each function it appears in.)
>>>> drivers/net/ibm_newemac/mal.c:285: error: implicit declaration of function 'mfdcri'
>>>> drivers/net/ibm_newemac/mal.c: In function 'mal_rxeob':
>>>> drivers/net/ibm_newemac/mal.c:302: error: 'SDR0' undeclared (first use in this function)
>>> That's annoying, I'll have a look.
>> Support for new features needed by the PPC 405EZ boards
>> introduced some errors in the MAL and EMAC feature handling.
>> This broke 'allmodconfig' builds as CONFIG_PPC_DCR_NATIVE is
>> not set for those.
>>
>> This patch fixes these errors by wrapping the code in the
>> appropriate #ifdefs.
>>
>> Signed-off-by: Josh Boyer <jwboyer@linux.vnet.ibm.com>
> 
> Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
> 
> Jeff, this breaks build, I'll put it in powerpc.git for a merge today,

ACK


