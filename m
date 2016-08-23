From: Kedari Appana <kedare06@gmail.com>
Subject: Re: [PATCH -next] net: phy: xgmiitorgmii: Fix non static symbol
 warning
Date: Tue, 23 Aug 2016 22:10:34 +0530
Message-ID: <CANdmM3O1BEZpwE_b9m1a_rOtz_LQLN=FRxhk7bcDOkECOjDeSA@mail.gmail.com>
References: <1471964765-32708-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
 michal.simek@xilinx.com, Wei Yongjun <weiyongjun1@huawei.com>,
 soren.brinkmann@xilinx.com, linux-arm-kernel@lists.infradead.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1471964765-32708-1-git-send-email-weiyj.lk@gmail.com>
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

HI,

        Thanks for the patch..

On Tue, Aug 23, 2016 at 8:36 PM, Wei Yongjun <weiyj.lk@gmail.com> wrote:
> From: Wei Yongjun <weiyongjun1@huawei.com>
>
> Fixes the following sparse warning:
>
> drivers/net/phy/xilinx_gmii2rgmii.c:61:5: warning:
>  symbol 'xgmiitorgmii_probe' was not declared. Should it be static?
>
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Acked by: Kedareswara rao Appana <appanad@xilinx.com>

> ---
>  drivers/net/phy/xilinx_gmii2rgmii.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/phy/xilinx_gmii2rgmii.c b/drivers/net/phy/xilinx_gmii2rgmii.c
> index e7a20ec..2e408b8 100644
> --- a/drivers/net/phy/xilinx_gmii2rgmii.c
> +++ b/drivers/net/phy/xilinx_gmii2rgmii.c
> @@ -58,7 +58,7 @@ static int xgmiitorgmii_read_status(struct phy_device *phydev)
>         return 0;
>  }
>
> -int xgmiitorgmii_probe(struct mdio_device *mdiodev)
> +static int xgmiitorgmii_probe(struct mdio_device *mdiodev)
>  {
>         struct device *dev = &mdiodev->dev;
>         struct device_node *np = dev->of_node, *phy_node;
>
