From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 2/2] hso: Fix stack corruption on some architectures
Date: Wed, 21 Aug 2013 20:48:19 -0700 (PDT)
Message-ID: <20130821.204819.740022331426748929.davem@davemloft.net>
References: <1377074599.4530.9.camel@chimera>
	<20130821162447.GC14364@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel-R/FLGEdV95bo9U+Z1CfBt0SU0eOFXohjCypLqA8HKkk@public.gmane.org, j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130821162447.GC14364-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Date: Wed, 21 Aug 2013 09:24:47 -0700

> On Wed, Aug 21, 2013 at 01:43:19AM -0700, Daniel Gimpelevich wrote:
>> As Sergei Shtylyov explained in the #mipslinux IRC channel: 
>> [Mon 2013-08-19 12:28:21 PM PDT] <headless> guys, are you sure it's not "DMA off stack" case?
>> [Mon 2013-08-19 12:28:35 PM PDT] <headless> it's a known stack corruptor on non-coherent arches
>> [Mon 2013-08-19 12:31:48 PM PDT] <DonkeyHotei> headless: for usb/ehci?
>> [Mon 2013-08-19 12:34:11 PM PDT] <DonkeyHotei> headless: explain
>> [Mon 2013-08-19 12:35:38 PM PDT] <headless> usb_control_msg() (or other such func) should not use buffer on stack. DMA from/to stack is prohibited
>> [Mon 2013-08-19 12:35:58 PM PDT] <headless> and EHCI uses DMA on control xfers (as well as all the others)
>> 
>> Signed-off-by: Daniel Gimpelevich <daniel-R/FLGEdV95bo9U+Z1CfBt0SU0eOFXohjCypLqA8HKkk@public.gmane.org>
> 
> Acked-by: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
