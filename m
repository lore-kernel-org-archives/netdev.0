From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 04/10] net: stmmac: sunxi platfrom
 extensions for GMAC in Allwinner A20 SoC's
Date: Mon, 09 Dec 2013 17:44:48 +0400
Message-ID: <52A5C950.7070903@cogentembedded.com>
References: <1386350983-13281-1-git-send-email-wens@csie.org> <1386350983-13281-5-git-send-email-wens@csie.org> <52A5A7B2.4000509@st.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
 linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
 Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
 Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: srinivas kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>,
 Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Return-path: <linux-sunxi+bncBC6MFNV32EFRBVUSS6KQKGQEFGTVJVQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <52A5A7B2.4000509-qxv4g6HH51o@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hello.

On 09-12-2013 15:21, srinivas kandagatla wrote:

>> +static int sun7i_gmac_init(struct platform_device *pdev)
>> +{
>> +	struct resource *res;
>> +	struct device *dev = &pdev->dev;
>> +	void __iomem *addr = NULL;
>> +	struct plat_stmmacenet_data *plat_dat = NULL;

    No need to initialize it since you're assigning to it right below.

>> +	u32 priv_clk_reg;
>> +
>> +	plat_dat = dev_get_platdata(&pdev->dev);
>> +	if (!plat_dat)
>> +		return -EINVAL;

> dev_get_platdata will return NULL for DT, So this function will fail all
> the time.

    Indeed, unless the probe() method assigns it from the 'data' field of
'struct of_device_id'.

> How is it supposed to work?
> Am I missing some thing?

    Look at stmmac_pltfr_probe().

> --srini

WBR, Sergei
