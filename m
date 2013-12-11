From: Nishanth Menon <nm-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH 1/2] net: smc91x: Read hardware behavior flags from device tree
Date: Wed, 11 Dec 2013 12:27:55 -0600
Message-ID: <CAGo_u6oHPJSfDF=9WVTb2ukmwxDoasho=4L7qJmnYng6-84N0Q@mail.gmail.com>
References: <1386757305-12545-1-git-send-email-nm@ti.com>
	<1386757305-12545-2-git-send-email-nm@ti.com>
	<20131211160440.GA13171@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: dt list <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	=?ISO-8859-1?Q?Beno=EEt_Cousson?= <bcousson-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
	linux-omap <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20131211160440.GA13171-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 11, 2013 at 10:04 AM, Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org> wrote:
> * Nishanth Menon <nm-l0cyMroinI0@public.gmane.org> [131211 02:23]:
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/smsc91x.txt
>> @@ -0,0 +1,45 @@
>> +* Smart Mixed-Signal Connectivity (SMSC) LAN91c94/91c111 Controller
>> +
>> +Required properties:
>> +- compatible : Should be one of:
>> +     "smsc,lan91c94"
>> +     "smsc,lan91c111"
>> +- reg : Address and length of the io space for SMSC LAN
>> +- interrupts : Should contain SMSC LAN interrupt line
>> +- interrupt-parent : Should be the phandle for the interrupt controller
>> +  that services interrupts for this device
>> +
>> +Optional properties:
>> +- reg-shift : Specify the quantity to shift the register offsets by
>> +- reg-io-width : Specify the size (in bytes) of the IO accesses that
>> +  should be performed on the device.  Valid value for SMSC LAN is
>> +  1, 2 or 4.
>
> I posted a minimal regression fix for this a few weeks ago that we
> should merge to the v3.13-rc cycle:
>
> http://www.spinics.net/lists/netdev/msg258913.html
>
> Care to ack that one?
Done.

> Then if that works for you, maybe rebase these on
> that one for the upcoming merge window?
it seems like omap is the only folks who are currently using this
driver in dt form, I kinda proposed to do these as add on changes to
your patch, lets see if anyone cares about it.

but I agree to drop my series at this point,

Regards,
Nishanth Menon
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
