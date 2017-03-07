From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 2/6] drivers: net: xgene-v2: Add mac
 configuration
Date: Tue, 07 Mar 2017 14:02:06 -0800 (PST)
Message-ID: <20170307.140206.2169938744916149211.davem@davemloft.net>
References: <1488589773-28055-1-git-send-email-isubramanian@apm.com>
 <1488589773-28055-3-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
 patches@apm.com, David.Laight@aculab.com, kchudgar@apm.com,
 linux-arm-kernel@lists.infradead.org
To: isubramanian@apm.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1488589773-28055-3-git-send-email-isubramanian@apm.com>
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

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Fri,  3 Mar 2017 17:09:28 -0800

> +void xge_mac_set_station_addr(struct xge_pdata *pdata)
> +{
> +	u32 addr0, addr1;
> +	u8 *dev_addr = pdata->ndev->dev_addr;

Please order local variable declarations from longest to shortest line.
