From: Grant Likely <grant.likely@linaro.org>
Subject: Re: [PATCH] DT: net: document Ethernet bindings in one place
Date: Thu, 06 Feb 2014 09:43:00 +0000
Message-ID: <20140206094301.03572C40B6A@trevor.secretlab.ca>
References: <201401180405.07859.sergei.shtylyov@cogentembedded.com> < CAL_Jsq+oa9P=rh+p-dMZyGP8TcmpX7bTnMU0ynLvFxjxFDYbRg@mail.gmail.com> < 52DD98F7.4090202@cogentembedded.com> < CAL_JsqJXbF1-PcPHR2VP+Vi9A1aWizdsG_r3kDvRt3itXDhCGQ@mail.gmail.com> < CAGVrzcb3X3soJNJCE5+YSpQrr+EdycCRFkptPvBCgFg4CbGJ4Q@mail.gmail.com> < CAGVrzcb0dfw1orZzUt5-YkShOg-HNbUYvvo2vfmsZUZXy1Aqfg@mail.gmail.com> < 52DEE465.9000202@cogentembedded.com> <52E988FA.8040807@cogentembedded.com> <20140204172602.01420C4050F@trevor.secretlab.ca> <52F13410.8070205@ cogentembedded.com> <20140205120843.9ED08C40A89@trevor.secretlab.ca> < 52F25A63.3010608@cogentembedded.com>
Cc: netdev <netdev@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Rob Landley <rob@landley.net>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Rob Herring <robherring2@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <52F25A63.3010608@cogentembedded.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 05 Feb 2014 18:36:03 +0300, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
> 
> On 02/05/2014 03:08 PM, Grant Likely wrote:
> 
> >>>>>>>>>       I'm afraid that's too late, it has spread very far, so that
> >>>>>>>>> of_get_phy_mode() handles that property, not "phy-connection-type".
> 
> >>>>>>>> Uggg, I guess this is a case of a defacto standard then if the kernel
> >>>>>>>> doesn't even support it.
> 
> >>>>>>> Maybe I forgot to CC you on patch sent to Grant only, I sent a patch a
> >>>>>>> while ago for of_get_phy_mode() to look for both "phy-mode" and
> >>>>>>> "phy-connection-type" since the former has been a Linux invention, but
> >>>>>>> the latter is ePAPR specified.
> 
> >>>>>> Here is a link to the actual patch in question, not sure which tree
> >>>>>> Grant applied it to though:
> 
> >>>>>> http://lkml.indiana.edu/hypermail/linux/kernel/1311.2/00048.html
> 
> >>>>>       It's not the patch mail, it's Grant's "applied" reply, patch is mangled in
> >>>>> this reply, and I couldn't follow the thread. Here's the actual patch mail:
> 
> >>>>> http://marc.info/?l=devicetree&m=138449662807254
> 
> >>>>       Florian, I didn't find this patch in Grant's official tree, so maybe you
> >>>> should ask him where is the patch already?
> 
> >>> Sorry, I accidentally dropped it. It will be in the next merge window.
> 
> >>      Already saw it, thanks. Would that it was in 3.14 instead of course, so
> >> that I could use "phy-connection-type" in my binding...
> 
> > Is 3.14 broken because of missing the patch? If so I'll get it merged as
>  > a bug fix.
> 
>     No, it's not. I could have used "phy-connection-type" in my binding 
> destined for 3.15 and document it as a preferred property as well.

You still can. We just need to make sure that your patch is applied on
top of the phy-connection-type patch.

g.

