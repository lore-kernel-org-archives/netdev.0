From: Daniel Trautmann <dtrautmann@ibhsoftec.com>
Subject: Re: [PATCH v2 0/3] drivers: net: cpsw: Fix bugs in fixed-link PHY DT
 parsing
Date: Fri, 18 Dec 2015 11:20:21 +0100
Message-ID: <20151218102020.GA1703@dt-ub1404lts.ENTWDOM.local>
References: <20151209223115.6c5a400f.drivshin.allworx@gmail.com>
 <1741588.Ve76Z1ZI87@localhost>
 <cover.1450309613.git.drivshin@allworx.com>
 <20151217.154508.505711333985621252.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, dtrautmann@ibhsoftec-sps.de,
 systemprogrammierung.brunner@gmail.com, netdev@vger.kernel.org,
 kernel@iktek.de, linux-omap@vger.kernel.org, drivshin.allworx@gmail.com,
 linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20151217.154508.505711333985621252.davem@davemloft.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 17, 2015 at 03:45:08PM -0500, David Miller wrote:
> From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
> Date: Wed, 16 Dec 2015 23:02:08 -0500
> 
> > I have tested on the following hardware configurations:
> >  - (EVMSK) dual emac with two real MDIO-connected phys using RGMII-TXID
> >  - single emac with fixed-link using RGMII
> > Testing of other CPSW emac configurations that folks may have would
> > be appreciated.
> 
> I'm going to wait until some others give some feedback and testing
> results on this one, thanks.

I can confirm that this patch is working on the following hardware setup:
 - single emac using MII connected with fixed-link to Micrel KSZ8895 Switch
