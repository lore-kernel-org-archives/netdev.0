From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: linux-next: Tree for Dec 20 (brocade/bna)
Date: Fri, 20 Dec 2013 12:52:30 -0800
Message-ID: <52B4AE0E.8070701@infradead.org>
References: <20131220172503.b2b7cb92f437d974f032e1a4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Rasesh Mody <rmody@brocade.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20131220172503.b2b7cb92f437d974f032e1a4@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/19/13 22:25, Stephen Rothwell wrote:
> Hi all,
> 
> Changes since 20131219:
> 


on i386:

drivers/net/ethernet/brocade/bna/bnad.c: In function 'bnad_start_xmit':
drivers/net/ethernet/brocade/bna/bnad.c:3074:26: error: 'struct bnad_tx_vector' has no member named 'dma_len'


CONFIG_NEED_DMA_MAP_STATE is not enabled.


-- 
~Randy
