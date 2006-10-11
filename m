From: Geoff Levand <geoffrey.levand@am.sony.com>
Subject: Re: [PATCH 21/21]: powerpc/cell spidernet DMA coalescing
Date: Tue, 10 Oct 2006 18:46:08 -0700
Message-ID: <452C4CE0.5010607@am.sony.com>
References: <20061010204946.GW4381@austin.ibm.com>	<20061010212324.GR4381@austin.ibm.com> <452C2AAA.5070001@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linas Vepstas <linas@austin.ibm.com>, akpm@osdl.org,
	jeff@garzik.org, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030748AbWJKBqV@vger.kernel.org>
To: jschopp <jschopp@austin.ibm.com>
In-Reply-To: <452C2AAA.5070001@austin.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jschopp wrote:
> Linas Vepstas wrote:
>> The current driver code performs 512 DMA mappns of a bunch of 
>> 32-byte structures. This is silly, as they are all in contiguous 
>> memory. Ths patch changes the code to DMA map the entie area
>> with just one call.
>> 
>> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
>> Cc: James K Lewis <jklewis@us.ibm.com>
>> Cc: Arnd Bergmann <arnd@arndb.de>
> 
> The others look good, but this one complicates the code and doesn't have any benefit.  20 
> for 21 isn't bad.

Linas, 

Is the motivation for this change to improve performance by reducing the overhead
of the mapping calls?  If so, there may be some benefit for some systems.  Could
you please elaborate?

-Geoff
