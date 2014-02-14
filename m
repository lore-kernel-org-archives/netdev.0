From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] DT: net: document Ethernet bindings in one place
Date: Sat, 15 Feb 2014 02:05:32 +0300
Message-ID: <52FEA13C.4080402@cogentembedded.com>
References: <201401180405.07859.sergei.shtylyov@cogentembedded.com> < CAL_Jsq+oa9P=rh+p-dMZyGP8TcmpX7bTnMU0ynLvFxjxFDYbRg@mail.gmail.com> < 52DD98F7.4090202@cogentembedded.com> < CAL_JsqJXbF1-PcPHR2VP+Vi9A1aWizdsG_r3kDvRt3itXDhCGQ@mail.gmail.com> < CAGVrzcb3X3soJNJCE5+YSpQrr+EdycCRFkptPvBCgFg4CbGJ4Q@mail.gmail.com> < CAGVrzcb0dfw1orZzUt5-YkShOg-HNbUYvvo2vfmsZUZXy1Aqfg@mail.gmail.com> < 52DEE465.9000202@cogentembedded.com> <52E988FA.8040807@cogentembedded.com> <20140204172602.01420C4050F@trevor.secretlab.ca> <52F13410.8070205@ cogentembedded.com> <20140205120843.9ED08C40A89@trevor.secretlab.ca> < 52F25A63.3010608@cogentembedded.com> <20140206094301.03572C40B6A@trevor. secretlab.ca> <52F396DE.8010306@cogentembedded.com> <20140210220541.C7A56C408F7@trevor.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>,
	"linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Rob Herring <robherring2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140210220541.C7A56C408F7-WNowdnHR2B42iJbIjFUEsiwD8/FfD2ys@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 02/11/2014 01:05 AM, Grant Likely wrote:

>>>>>>>>>>>>>         I'm afraid that's too late, it has spread very far, so that
>>>>>>>>>>>>> of_get_phy_mode() handles that property, not "phy-connection-type".

>>>>>>>>>>>> Uggg, I guess this is a case of a defacto standard then if the kernel
>>>>>>>>>>>> doesn't even support it.

>>>>>>>>>>> Maybe I forgot to CC you on patch sent to Grant only, I sent a patch a
>>>>>>>>>>> while ago for of_get_phy_mode() to look for both "phy-mode" and
>>>>>>>>>>> "phy-connection-type" since the former has been a Linux invention, but
>>>>>>>>>>> the latter is ePAPR specified.

>>>>>>>>>> Here is a link to the actual patch in question, not sure which tree
>>>>>>>>>> Grant applied it to though:

>>>>>>>>>> http://lkml.indiana.edu/hypermail/linux/kernel/1311.2/00048.html

>>>>>>>>>         It's not the patch mail, it's Grant's "applied" reply, patch is mangled in
>>>>>>>>> this reply, and I couldn't follow the thread. Here's the actual patch mail:

>>>>>>>>> http://marc.info/?l=devicetree&m=138449662807254

>>>>>>>>         Florian, I didn't find this patch in Grant's official tree, so maybe you
>>>>>>>> should ask him where is the patch already?

>>>>>>> Sorry, I accidentally dropped it. It will be in the next merge window.

>>>>>>        Already saw it, thanks. Would that it was in 3.14 instead of course, so
>>>>>> that I could use "phy-connection-type" in my binding...

>>>>> Is 3.14 broken because of missing the patch? If so I'll get it merged as
>>>>> a bug fix.

>>>>       No, it's not. I could have used "phy-connection-type" in my binding
>>>> destined for 3.15 and document it as a preferred property as well.

>>> You still can. We just need to make sure that your patch is applied on

>>      Patches.

>>> top of the phy-connection-type patch.

>>      I'm not sure this trick is possible if the patches are merged via the
>> different trees...

> There are two ways to do it. A) by having a common merge commit
> containing that patch and merged into both branches, or B) just merging
> the patch in the same tree.

> Normally I'd suggest B), but I've already picked up the patch and I try
> very hard not to rebase my commit tree. However, since the branch is
> stable, you can ask for my branch to be merged into the net branch
> before applying the dependant patches. The relevant commit id is
> cf4c9eb5a4, and it is in my devicetree/next branch on
> git://git.secretlab.ca/git/linux

    David, would it be possible for you to merge this into net-next?

> g.

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
