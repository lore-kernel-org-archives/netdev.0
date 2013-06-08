From: Vineet Gupta <Vineet.Gupta1-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v2] ethernet/arc/arc_emac - Add new driver
Date: Sat, 8 Jun 2013 16:53:46 +0530
Message-ID: <51B31442.5020707@synopsys.com>
References: <1370617656-18349-1-git-send-email-abrodkin@synopsys.com>
 <1370628783.2209.123.camel@joe-AO722>
 <4881796E12491D4BB15146FE0209CE643F5CA32B@DE02WEMBXB.internal.synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>,
 "devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org"
 <devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
 "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Vineet Gupta <Vineet.Gupta1-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
 Alexey Brodkin <Alexey.Brodkin-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
 "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 Grant
 Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, "romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org" <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>,
 Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, Mischa Jonker <Mischa.Jonker-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
To: Alexey Brodkin <Alexey.Brodkin-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <4881796E12491D4BB15146FE0209CE643F5CA32B-okAzG6w2b9vBRDCkatnZjvufCSb+aD3WLzEdoUbNIic@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 06/08/2013 04:49 PM, Alexey Brodkin wrote:
>  >> +	if (!priv->phy_node) {
>  >> +		dev_err(&pdev->dev, "failed to retrieve phy description "
>  >> +			"from device tree\n");
>  >
>  > Coalesce formats please
>
> Could you please clarify how should I format lines in question?
> I'm a bit lost here.

Don't break the string - even if line becomes > 80 chars. This is to help with
grep and such.

-Vineet
