From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH v1 1/2] dtb: xgene: fix: Disable 10GbE and SGMII based 1GbE by default
Date: Tue, 04 Nov 2014 10:40:18 +0100
Message-ID: <2461768.hHqNmTQE9x@wuerfel>
References: <1414630580-24640-1-git-send-email-isubramanian@apm.com> <1991367.DGHysZpQVP@wuerfel> <CAKh23FkVrPdCuR6dn1S4RvW14_f4Xq8MWaChUh9DyVp44kVtSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, patches <patches-qTEPVZfXA3Y@public.gmane.org>,
	Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKh23FkVrPdCuR6dn1S4RvW14_f4Xq8MWaChUh9DyVp44kVtSg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 03 November 2014 11:45:44 Iyappan Subramanian wrote:
> 
> On Thu, Oct 30, 2014 at 3:13 AM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> > On Wednesday 29 October 2014 17:56:19 Iyappan Subramanian wrote:
> >> @@ -621,7 +621,7 @@
> >>                         };
> >>                 };
> >>
> >> -               sgenet0: ethernet@1f210000 {
> >> +               sgenet0: sgenet@1f210000 {
> >>                         compatible = "apm,xgene-enet";
> >>                         status = "disabled";
> >>                         reg = <0x0 0x1f210000 0x0 0x10000>,
> >>
> >
> > This looks like you accidentally reverted a bug fix made earlier.
> > Network devices should always have the name 'ethernet@...'.
> 
> Thanks for the review.  Since our firmware was patching the dtb, based
> on the node-name, we thought by changing node-name, we can avoid the
> patching and maintain backward compatibility.
> 
> Now we know that network devices should have 'ethernet@...', we will
> handle the backward compatibility in a different way and will post the
> patch v2 shortly.

It's not important enough to break backwards compatibility over this.
If you can't find a better way to handle compatibility with the old
firmware, just add a comment explaining the node name.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
