From: Alexandre Torgue <alexandre.torgue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v5 2/4] Documentation: Bindings: Add STM32 DWMAC glue
Date: Tue, 22 Mar 2016 17:11:33 +0100
Message-ID: <CAJgp7zxfFRhfNjcE23n+DKD0ffrvH4_sowPjK_-DZAS4ecH5dg@mail.gmail.com>
References: <1458315428-10081-1-git-send-email-alexandre.torgue@gmail.com>
	<1458315428-10081-3-git-send-email-alexandre.torgue@gmail.com>
	<CAGb2v65SvVi0cJbaaD9cYrqC3pJ9eumwhTVk11_N7r_nTZhS9g@mail.gmail.com>
	<20160321124043.GA26873@rob-hp-laptop>
	<CAGhQ9VwS=YwgfeUuK+LzGjy3f9btVGV7bN=TATGHwQs+JW+iGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Maxime Coquelin <mcoquelin.stm32-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGhQ9VwS=YwgfeUuK+LzGjy3f9btVGV7bN=TATGHwQs+JW+iGA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi guys,

I will fix typo issues (s/vesrion/version and ethernet @).

Concerning compatible string. For sure "snps,dwmac-3.50a" string is
not used inside glue driver.
I perfere to keep it for information but if you really want that I
remove it I will not block ;)

2016-03-21 16:36 GMT+01:00 Joachim  Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
> On 21 March 2016 at 13:40, Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>> On Sat, Mar 19, 2016 at 12:00:22AM +0800, Chen-Yu Tsai wrote:
>>> Hi,
>>>
>>> On Fri, Mar 18, 2016 at 11:37 PM, Alexandre TORGUE
>>> <alexandre.torgue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>> > +- clocks: Must contain a phandle for each entry in clock-names.
>>> > +- clock-names: Should be "stmmaceth" for the host clock.
>>
We can remove host clock (stmmac eth) entry here and refer to
stmmac.txt binding for common entry

>> This doesn't sound like the clock input signal name...
>>
>>> > +              Should be "tx-clk" for the MAC TX clock.
>>> > +              Should be "rx-clk" for the MAC RX clock.
>>
>> How can other DWMAC blocks not have these clocks? The glue can't really
>> add these clocks. It could combine them into one or a new version of
>> DWMAC could have a different number of clock inputs. So if there is
>> variation here, then some of the bindings are probably wrong. I guess
>> the only change I'm suggesting is possibly moving these into common
>> binding doc.
>
> The LPC18xx implementation probably have these clocks as well but the
> LPC1850 user manual only documents the main clock. Someone with access
> to the IP block doc from Synopsys should be able to check which clocks
> the MAC really needs.
>
> Rockchip bindings have two clocks named "mac_clk_rx" and "mac_clk_tx".
> These are probably the same as stm32 needs so maybe use these names
> and move them into the main doc and update the rockchip binding.
>
I think we can use same name. But I have a doubt on moving it in a
common bindings (maybe I don't well understood). When you say "common
binding file" is it "stmmac.txt" binding ? If yes does it mean that we
have to control it inside stmmac driver (no more in glue) ? In this
case those clocks will become "required" for stm32 and rockship but
not for others chip. It could create confusion?

Best regards

Alex

>
> regards,
> Joachim Eastwood
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
