From: Thomas Kear <thomas-hrxM1pTBpuF02iOg2JU2CQ@public.gmane.org>
Subject: Re: PROBLEM: usbnet / ax88179_178a: Panic in usb_hcd_map_urb_for_dma
Date: Sat, 11 Jan 2014 12:41:06 +1300
Message-ID: <CAHNSM4KU8QEybpHgAcCjQoWuRjU8=wd1O7KUVMnrRJKQ-xr=Gg@mail.gmail.com>
References: <CAHNSM4Kv5gcJn=H4k8QjPggWzjF0zRm_t_icAYXjCTqXx4xL2w@mail.gmail.com>
 <1389385824.2025.95.camel@bwh-desktop.uk.level5networks.com> <87ob3j1ocb.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87ob3j1ocb.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 11, 2014 at 11:09 AM, Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote=
:
> But looking at the code I think I found and obvious miss in the SG li=
st
> initialisation.  I'll post a proposed fix for that.  Would be good if
> someone was able to test it.

I've built 3.13.0-rc7-next-20140110 with your patch applied.
Unfortunately since this bug has taken anywhere from minutes to days
to manifest previously I'm not sure how quickly I'll be able to report
on its efficacy.

I currently have the adapter plugged in through a 4-port USB3 hub
(2109:0811, which appears to be a VIA chip) but I will test it
directly attached to the laptop too.

-Thomas
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
