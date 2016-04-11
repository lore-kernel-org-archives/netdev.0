From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH RFT 2/2] macb: kill PHY reset code
Date: Mon, 11 Apr 2016 20:51:15 +0200
Message-ID: <20160411185115.GA30623@lunn.ch>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <2811962.eGX2i5RJbZ@wasted.cogentembedded.com>
 <20160411022802.GB4307@lunn.ch>
 <570BE1C5.70502@cogentembedded.com>
 <20160411181904.GB29709@lunn.ch>
 <570BEF46.7060105@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <570BEF46.7060105-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 11, 2016 at 09:39:02PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 04/11/2016 09:19 PM, Andrew Lunn wrote:
> 
> >>>The code you are deleting would of ignored the flags in the gpio
> >>>property, i.e. active low.
> >>
> >>    Hm, you're right -- I forgot about that... :-/
> >>
> >>>The new code in the previous patch does
> >>>however take the flags into account. Did you check if there are any
> >>>device trees which have flags, which were never used, but are now
> >>>going to be used and thus break...
> >>
> >>    Checked this now and found out arch/arm/boot/dts/ar91-vinco.dts.
> >>Looks like it needs to be fixed indeed...
> >>
> >And this is where it gets tricky. You are breaking backwards
> >compatibility by now respecting the flag. An old DT blob is not going
> >to work.
> 
>    Do we care that much about the DT blobs that are just *wrong*?

Wrong, but currently works.

> >You potentially need to add a new property and deprecate the old one.
> 
>    I would like to avoid that...

You will need the agreement from the at91-vinco maintainer.

    Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
