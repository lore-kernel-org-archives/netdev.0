From: Mark Greer <mgreer-luAo+O/VEmrlveNOaEYElw@public.gmane.org>
Subject: Re: [PATCH 2/3] NFC: trf7970a: Add device tree option of 1.8 Volt IO
 voltage
Date: Tue, 20 Dec 2016 19:07:17 -0700
Message-ID: <20161221020717.GA5444@animalcreek.com>
References: <1481841044-4314-1-git-send-email-glansberry@gmail.com>
 <1481841044-4314-2-git-send-email-glansberry@gmail.com>
 <20161219223504.ttwayzpfvdumgouu@rob-hp-laptop>
 <CAO7Z3WLC7J+JzmtArOc-ZUNoLGeMX6s=1XQbzwB1zx1U3yTX2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
        Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
        Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Justin Bronder <justin-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>
To: Geoff Lansberry <geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAO7Z3WLC7J+JzmtArOc-ZUNoLGeMX6s=1XQbzwB1zx1U3yTX2Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 20, 2016 at 11:13:23AM -0500, Geoff Lansberry wrote:
> On Mon, Dec 19, 2016 at 5:35 PM, Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> > On Thu, Dec 15, 2016 at 05:30:43PM -0500, Geoff Lansberry wrote:
> >> From: Geoff Lansberry <geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>
> >>
> >> ---
> >>  Documentation/devicetree/bindings/net/nfc/trf7970a.txt |  2 ++
> >>  drivers/nfc/trf7970a.c                                 | 13 ++++++++++++-
> >>  2 files changed, 14 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt b/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
> >> index 9dda879..208f045 100644
> >> --- a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
> >> +++ b/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
> >> @@ -21,6 +21,7 @@ Optional SoC Specific Properties:
> >>  - t5t-rmb-extra-byte-quirk: Specify that the trf7970a has the erratum
> >>    where an extra byte is returned by Read Multiple Block commands issued
> >>    to Type 5 tags.
> >> +- vdd_io_1v8: Set to specify that the trf7970a io voltage should be set to 1.8V
> >
> > Use the regulator binding and provide a fixed 1.8V supply.
> >
> >>  - crystal_27mhz: Set to specify that the input frequency to the trf7970a is 27.12MHz
> >>
> >>
> >> @@ -45,6 +46,7 @@ Example (for ARM-based BeagleBone with TRF7970A on SPI1):
> >>               irq-status-read-quirk;
> >>               en2-rf-quirk;
> >>               t5t-rmb-extra-byte-quirk;
> >> +             vdd_io_1v8;
> >>               crystal_27mhz;
> >>               status = "okay";
> >>       };
> 
> Rob - using the regulator binding is new to me, but I've given it a
> shot and just sent you another set of patches for your inspection.
> Please let me know if this is what you had in mind.

This is my bad.  Geoff followed my example and did something similar to
'vin-voltage-override' which shouldn't have been there in the first place.
I have this fixed (I think) locally and will submit once it I'm back from
my holiday travels.

Mark
--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
