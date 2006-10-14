From: Joel Schopp <jschopp@austin.ibm.com>
Subject: Re: [PATCH 21/21]: powerpc/cell spidernet DMA coalescing
Date: Fri, 13 Oct 2006 21:12:01 -0500
Message-ID: <45304771.70606@austin.ibm.com>
References: <20061010204946.GW4381@austin.ibm.com>
	<20061010212324.GR4381@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, jeff@garzik.org, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20061010212324.GR4381@austin.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
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

While this patch wasn't useful in the current cell implementation of pci_map_single 
it sounds like people are going to be making changes to that sometime. In light of 
that new information (new to me anyway) this should probably go in after all.  Sorry 
for causing trouble.

Acked-by: Joel Schopp <jschopp@austin.ibm.com>
