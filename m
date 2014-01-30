From: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: Help testing for USB ethernet/xHCI regression
Date: Thu, 30 Jan 2014 15:26:29 -0800
Message-ID: <20140130232629.GF14228@xanatos>
References: <22081260.RNay0J72dY@athas>
 <20140129215408.GC5991@xanatos>
 <063D6719AE5E284EB5DD2968C1650D6D0F6ACF20@AcuExch.aculab.com>
 <20140130184412.GA3787@xanatos>
 <A2CA0424C0A6F04399FB9E1CD98E03046D147453@US01WEMBX2.internal.synopsys.com>
 <52EAAF6F.7070202@pobox.com>
 <20140130214133.GB14228@xanatos>
 <52EAD038.5020409@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Zimmerman <paulz-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
	David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
	"renevant-CkBdp7X+a1oIQCUVoCVjmQ@public.gmane.org" <renevant-CkBdp7X+a1oIQCUVoCVjmQ@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Mark Lord <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <52EAD038.5020409-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 30, 2014 at 05:20:40PM -0500, Mark Lord wrote:
> On 14-01-30 04:41 PM, Sarah Sharp wrote:
> >
> > Mark and David, can you pull the 3.13-td-changes-reverted branch again,
> > and see if the latest patch fixes your issue?  It disables scatter
> > gather for the ax88179_178a device, but only when it's operating at USB
> > 3.0 speeds.
> 
> As expected, this works just fine.

Did it work when plugged into a USB 2.0 hub?

Sarah Sharp
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
