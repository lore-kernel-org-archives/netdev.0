From: Kunihiko Hayashi <hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH net-next v2 2/2] net: ethernet: socionext: add AVE ethernet driver
Date: Thu, 19 Oct 2017 19:35:40 +0900
Message-ID: <20171019193540.0F35.4A936039@socionext.com>
References: <20171018192359.243C.4A936039@socionext.com> <CAK7LNARuoK-M9iKyP7JxRgH7naA+teikqZMOHm3f2wykEieqLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Masami Hiramatsu <masami.hiramatsu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Jassi Brar <jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAK7LNARuoK-M9iKyP7JxRgH7naA+teikqZMOHm3f2wykEieqLw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Oct 2017 09:29:03 +0900 <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org> wrote:

> 2017-10-18 19:23 GMT+09:00 Kunihiko Hayashi <hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>:
> > On Mon, 16 Oct 2017 00:08:21 +0900 <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org> wrote:
> 
> >> priv->rst = devm_reset_control_get_optional_shared(dev, NULL);
> >> if (IS_ERR(priv->rst))
> >>           return PTR_ERR(priv->rst);
> >
> > The clk and reset are optional in the driver.
> > Referring to your suggested method, I'll fix the part of clk and reset.
> >
> 
> 
> Why is clk optional?

Indeed. My check point was wrong.
This clk property should be treated as "required".

In v2, the clock enabling code moved to ndo_init().
Although probing the driver succeeds without clk,
enabling the driver fails clearly.

---
Best Regards,
Kunihiko Hayashi


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
