From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH v4] net: ethernet: faraday: To support device tree usage.
Date: Wed, 25 Jan 2017 22:09:20 +0100
Message-ID: <CAK8P3a2Zr6=4x8JRa313DQ2ND0V=8eL0yKkrd93wbdxkiOtmSw@mail.gmail.com>
References: <20170124084606.GA11764@app09> <20170125.123448.742815192519658537.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: green.hu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Networking <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170125.123448.742815192519658537.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 25, 2017 at 6:34 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: Greentime Hu <green.hu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Tue, 24 Jan 2017 16:46:14 +0800
>> We also use the same binding document to describe the same faraday ethernet
>> controller and add faraday to vendor-prefixes.txt.
>
> Why are you renaming the MOXA binding file instead of adding a completely new one
> for faraday?  The MOXA one should stick around, I don't see a justification for
> removing it.

This was my suggestion, basically fixing the name of the existing
binding, which was
accidentally named after one of the users rather than the company that did the
hardware.

We can't change the compatible string, but I'd much prefer having only
one binding
file for this device rather than two separate ones that could possibly become
incompatible in case we add new properties to them. If there is only
one of them,
naming it according to the hardware design is the general policy.

Note that we currently have two separate device drivers, but that is more a
historic artifact, and if we ever get around to merging them into one driver,
that should not impact the binding.

    Arnd
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
