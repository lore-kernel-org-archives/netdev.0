From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH net v2 0/3] drivers: net: cpsw: phy-handle fixes
Date: Fri, 22 Apr 2016 12:25:29 +0530
Message-ID: <5719CAE1.40801@ti.com>
References: <1461261035-5578-1-git-send-email-drivshin.allworx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, Grygorii Strashko <grygorii.strashko@ti.com>,
 Markus Brunner <systemprogrammierung.brunner@gmail.com>,
 Nicolas Chauvet <kwizart@gmail.com>, linux-kernel@vger.kernel.org,
 Andrew Goodbody <andrew.goodbody@cambrionix.com>,
 David Miller <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>,
 <netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1461261035-5578-1-git-send-email-drivshin.allworx@gmail.com>
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

On Thursday 21 April 2016 11:20 PM, David Rivshin (Allworx) wrote:
> From: David Rivshin <drivshin@allworx.com>
> 
> The first patch fixes a bug that makes dual_emac mode break if
> either slave uses the phy-handle property in the devicetree.
> 
> The second patch fixes some cosmetic problems with error messages,
> and also makes the binding documentation more explicit.
> 
> The third patch cleans up the fixed-link case to work like
> the now-fixed phy-handle case.
> 
> I have tested on the following hardware configurations:
>  - (EVMSK) dual emac, phy_id property in both slaves
>  - (EVMSK) dual emac, phy-handle property in both slaves
>  - (BeagleBoneBlack) single emac, phy_id property
>  - (custom) single emac, fixed-link subnode
> 
> Nicolas Chauvet reported testing on an HP t410 (dm8148).
> 
> Markus Brunner reported testing v1 on the following [1]:
>  - emac0 with phy_id and emac1 with fixed phy
>  - emac0 with phy-handle and emac1 with fixed phy
>  - emac0 with fixed phy and emac1 with fixed phy
> 
> 

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
