From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 2/2] hso: Fix stack corruption on some architectures
Date: Wed, 21 Aug 2013 09:24:47 -0700
Message-ID: <20130821162447.GC14364@kroah.com>
References: <1377074599.4530.9.camel@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: j.dumon@option.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1377074599.4530.9.camel@chimera>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 21, 2013 at 01:43:19AM -0700, Daniel Gimpelevich wrote:
> As Sergei Shtylyov explained in the #mipslinux IRC channel: 
> [Mon 2013-08-19 12:28:21 PM PDT] <headless> guys, are you sure it's not "DMA off stack" case?
> [Mon 2013-08-19 12:28:35 PM PDT] <headless> it's a known stack corruptor on non-coherent arches
> [Mon 2013-08-19 12:31:48 PM PDT] <DonkeyHotei> headless: for usb/ehci?
> [Mon 2013-08-19 12:34:11 PM PDT] <DonkeyHotei> headless: explain
> [Mon 2013-08-19 12:35:38 PM PDT] <headless> usb_control_msg() (or other such func) should not use buffer on stack. DMA from/to stack is prohibited
> [Mon 2013-08-19 12:35:58 PM PDT] <headless> and EHCI uses DMA on control xfers (as well as all the others)
> 
> Signed-off-by: Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
