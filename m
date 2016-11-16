From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH] net: ethernet: faraday: To support device tree usage.
Date: Wed, 16 Nov 2016 17:12:44 +0100
Message-ID: <7309308.u1IWIyx3Gm@wuerfel>
References: <1479285795-3105-1-git-send-email-green.hu@gmail.com> <CAEbi=3esyRi4cnUNf4uPKCQtyRekBRo81Frd=BSJy8qf=3uc+A@mail.gmail.com> <20161116143715.GH19962@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Greentime Hu <green.hu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161116143715.GH19962-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday, November 16, 2016 3:37:15 PM CET Andrew Lunn wrote:
> On Wed, Nov 16, 2016 at 10:26:52PM +0800, Greentime Hu wrote:
> > On Wed, Nov 16, 2016 at 9:47 PM, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org> wrote:
> > > On Wed, Nov 16, 2016 at 04:43:15PM +0800, Greentime Hu wrote:
> > >> To support device tree usage for ftmac100.
> > >>
> > >> Signed-off-by: Greentime Hu <green.hu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > >> ---
> > >>  drivers/net/ethernet/faraday/ftmac100.c |    7 +++++++
> > >>  1 file changed, 7 insertions(+)
> > >>
> > >> diff --git a/drivers/net/ethernet/faraday/ftmac100.c b/drivers/net/ethernet/faraday/ftmac100.c
> > >> index dce5f7b..81dd9e1 100644
> > >> --- a/drivers/net/ethernet/faraday/ftmac100.c
> > >> +++ b/drivers/net/ethernet/faraday/ftmac100.c
> > >> @@ -1172,11 +1172,17 @@ static int __exit ftmac100_remove(struct platform_device *pdev)
> > >>       return 0;
> > >>  }
> > >>
> > >> +static const struct of_device_id mac_of_ids[] = {
> > >> +     { .compatible = "andestech,atmac100" },
> > >> +     { }
> > >
> > > andestech is not in
> > > Documentation/devicetree/bindings/vendor-prefixes.txt Please provide a
> > > separate patch adding it.
> > OK. I will provide another patch to add andestech.
> > 
> > > Humm, why andestech? Why not something based around faraday
> > > technology?
> > It is because we use the same ftmac100 IP provided from faraday
> > technology but I am now using it in andestech SoC.
> 
> Please make sure you get an acked-by: from the device tree
> maintainers. They might want you to use faraday, since that is the
> original IP provider. For example, all Synopsys licensed IP uses
> "snps,XXX", not the SoC vendor with the license.

I think ideally we have both the ID from andes and from faraday here.

Note that we already have "moxa,moxart-mac" as a compatible string
for this hardware, though it uses a different driver.

We should probably have a single binding document describing
both compatible strings and any optional properties.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
