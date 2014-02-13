From: Dinh Nguyen <dinh.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCHv3 1/2] net: stmmac: Add SOCFPGA glue driver
Date: Wed, 12 Feb 2014 22:33:14 -0600
Message-ID: <52FC4B0A.4010406@gmail.com>
References: <1392061697-20193-1-git-send-email-dinguyen@altera.com> <20140212.193539.38124529344029793.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org, ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org,
	galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, vbridgers2013-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140212.193539.38124529344029793.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On 2/12/14 6:35 PM, David Miller wrote:
> From: <dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
> Date: Mon, 10 Feb 2014 13:48:16 -0600
>
>> From: Dinh Nguyen <dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
>>
>> Like the STi series SOCs, Altera's SOCFPGA also needs a glue layer on top of the
>> Synopsys gmac IP.
>>
>> This patch adds the platform driver for the glue layer which configures the IP
>> before the generic STMMAC driver takes over.
>>
>> Signed-off-by: Dinh Nguyen <dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
>> Cc: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
>> Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>> Cc: Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>
>> Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
>> Cc: Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
>> Cc: Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
>> Cc: Vince Bridgers <vbridgers2013-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>> v3: Remove stray empty line at end of dwmac-socfpga.c.
>> v2: Use the dwmac-sti as an example for a glue layer and split patch up
>> to have dts as a separate patch. Also cc dts maintainers since there is
>> a new binding.
> The second patch for the DTS update doesn't apply cleanly at all to
> mainline.
Yes, I'm planning to take the DTS bindings patch through arm-soc/next-dt
tree, so that is where patch 2 is based on.
>
> Why don't you push both of these patches through whatever tree that
> file is maintained under.  You can add my ack:
I'm not sure if Peppe has a tree, but it should go into his tree
if there is one. If not, can you apply patch 1 to your tree?
>
> Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Thanks,
Dinh
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
