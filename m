From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 1/6] rapidio: add common mapping APIs for RapidIO memory
	access
Date: Wed, 10 Jun 2009 23:13:00 -0500
Message-ID: <90AED712-28A1-4800-978C-125A887D0DA7@kernel.crashing.org>
References: <1242117363-14949-1-git-send-email-leoli@freescale.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Content-Transfer-Encoding: 7bit
Cc: Zhang Wei <zw@zh-kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	linuxppc-dev@ozlabs.org, akpm@linux-foundation.org
To: Li Yang <leoli@freescale.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1242117363-14949-1-git-send-email-leoli@freescale.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org


On May 12, 2009, at 3:35 AM, Li Yang wrote:

> Add the mapping functions used to support direct IO memory access of
> rapidIO.
>
> Signed-off-by: Zhang Wei <zw@zh-kernel.org>
> Signed-off-by: Li Yang <leoli@freescale.com>

Use inbnd/outbnd instead of inb/outb which make one think of byte  
level io accessors.

As I look at this I don't think this is the correct API.  I think we  
should be using the DMA mapping API to hide these details.  The  
concept of mapping like this seems to be more a function of FSL's  
Address translation/mapping unit (ATMU) than anything specific to the  
RIO bus standard.

> ---
> drivers/rapidio/rio.c   |   95 ++++++++++++++++++++++++++++++++++++++ 
> +++++++++
> include/linux/rio.h     |   25 ++++++++++++
> include/linux/rio_drv.h |   24 +++++++++---
> 3 files changed, 138 insertions(+), 6 deletions(-)

- k
