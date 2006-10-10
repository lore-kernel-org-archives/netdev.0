From: jschopp <jschopp@austin.ibm.com>
Subject: Re: [PATCH 21/21]: powerpc/cell spidernet DMA coalescing
Date: Tue, 10 Oct 2006 18:20:10 -0500
Message-ID: <452C2AAA.5070001@austin.ibm.com>
References: <20061010204946.GW4381@austin.ibm.com> <20061010212324.GR4381@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, jeff@garzik.org, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:62860 "EHLO
	e36.co.us.ibm.com") by vger.kernel.org with ESMTP id S1030333AbWJJXUO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 19:20:14 -0400
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20061010212324.GR4381@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> The current driver code performs 512 DMA mappns of a bunch of 
> 32-byte structures. This is silly, as they are all in contiguous 
> memory. Ths patch changes the code to DMA map the entie area
> with just one call.
> 
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> Cc: James K Lewis <jklewis@us.ibm.com>
> Cc: Arnd Bergmann <arnd@arndb.de>

The others look good, but this one complicates the code and doesn't have any benefit.  20 
for 21 isn't bad.
