From: Jon Smirl <jonsmirl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][WIP] IEEE 802.15.4 implementation for Linux v1
Date: Fri, 5 Jun 2009 08:58:07 -0400
Message-ID: <9e4733910906050558h44382214m30fb8c9c7bbba63@mail.gmail.com>
References: <1243868091-5315-1-git-send-email-dbaryshkov@gmail.com>
	 <9e4733910906042103q6c21886cia02d33cb278cef1e@mail.gmail.com>
	 <bc64b4640906042149pb83911bk4e0397da11f9fde6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org,
	maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org, dmitry.baryshkov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	oliver.fendt-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org
To: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <bc64b4640906042149pb83911bk4e0397da11f9fde6-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 5, 2009 at 12:49 AM, Dmitry
Eremin-Solenikov<dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> 2009/6/5 Jon Smirl <jonsmirl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
>> On Mon, Jun 1, 2009 at 10:54 AM, Dmitry
>> Eremin-Solenikov<dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>> Hi,
>>>
>>> As a part of research activities the Embedded Systems - Open Platform Group
>>> from Siemens Corporate Technology we are working on adding support for
>>> the IEEE 802.15.4 Wireless Personal Area Networks to the Linux. Our current
>>> implementation is neither certified nor even feature complete. However
>>> we'd like to present current state of our patchset to the Linux developers
>>> community to gain comments, fixes, ideas, etc. This is not yet a pull request,
>>> but more like an RFC.
>>
>> Does this stack work with the Atmel USB version of at86rf230?
>> ATAVRRZUSBSTICK, http://www.atmel.com/dyn/products/tools_card.asp?tool_id=4396
>
> No, we do not support Atmel USB sticks, nor we do not have plans for
> adding support
> for it in the foreseable feature. However if the onboard ATmega can be
> programmed to
> provide usb-serial interface, one can use/adapt our serial discipline
> driver to control it.
> One will still have to write firmware for the on-stick ATmega chip.
>
> Or you can add support for any existing interface that is provided by
> RazorUSB card by yourself.
> We tried to make mac802154 drivers easy to implement.
>
>> It's not so simple to plug in the at86rf230 using SPI. Supporting USB
>> sticks lets you develop on a desktop PC.
>
> Hmm. One can solder (e.g.) the FTDI 2232 together with AT86RF230/231
> and use that combo
> instead of RazorUSB sticks.

Everything is there on USB stick. Interface, Zigbee chip, antenna, power, etc..
And they are cheap $40.

>
>> freaklabs.org is using ATAVRRZUSBSTICK
>
> I'll look for the interface they are using to control sticks and check
> how easy will it be to
> write a driver for it.

For development purposes you don't want to download the stack into the
USB stick, you just want to use USB as a transparent pass-through to
the Zigbee chip.

I have a Raven kit ordered, it will be here next week.


> --
> With best wishes
> Dmitry
>



-- 
Jon Smirl
jonsmirl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
