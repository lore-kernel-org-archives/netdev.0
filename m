From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net: dm9000: Allow instantiation using device tree
Date: Sun, 19 May 2013 10:38:22 +0200
Message-ID: <20130519083822.GA31087@electric-eye.fr.zoreil.com>
References: <1368918194-24030-1-git-send-email-tomasz.figa@gmail.com>
 <20130519070538.GX32299@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
 Tomasz Figa <tomasz.figa@gmail.com>, Rob Herring <rob.herring@calxeda.com>,
 Grant Likely <grant.likely@linaro.org>, Sascha Hauer <s.hauer@pengutronix.de>,
 linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20130519070538.GX32299@pengutronix.de>
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

Sascha Hauer <s.hauer@pengutronix.de> :
[...]
> > +#ifdef CONFIG_OF
> > +static struct dm9000_plat_data *dm9000_parse_dt(struct device *dev)
> > +{
> > +	struct dm9000_plat_data *pdata;
> > +	struct device_node *np = dev->of_node;
> > +	const void *prop;
> > +	int len;
> > +
> > +	if (!np)
> > +		return NULL;
> 
> You should be able to kill the ifdef around this function by doing
> 
> 	if (!IS_ENABLED(CONFIG_OF) || !np)
> 		return NULL;

It will be the first such use of IS_ENABLED in net land.

David, is it ok ?

-- 
Ueimor
