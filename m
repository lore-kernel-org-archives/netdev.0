From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] DT: net: document Ethernet bindings in one place
Date: Wed, 05 Feb 2014 18:36:03 +0300
Message-ID: <52F25A63.3010608@cogentembedded.com>
References: <201401180405.07859.sergei.shtylyov@cogentembedded.com> < CAL_Jsq+oa9P=rh+p-dMZyGP8TcmpX7bTnMU0ynLvFxjxFDYbRg@mail.gmail.com> < 52DD98F7.4090202@cogentembedded.com> < CAL_JsqJXbF1-PcPHR2VP+Vi9A1aWizdsG_r3kDvRt3itXDhCGQ@mail.gmail.com> < CAGVrzcb3X3soJNJCE5+YSpQrr+EdycCRFkptPvBCgFg4CbGJ4Q@mail.gmail.com> < CAGVrzcb0dfw1orZzUt5-YkShOg-HNbUYvvo2vfmsZUZXy1Aqfg@mail.gmail.com> < 52DEE465.9000202@cogentembedded.com> <52E988FA.8040807@cogentembedded.com> <20140204172602.01420C4050F@trevor.secretlab.ca> <52F13410.8070205@ cogentembedded.com> <20140205120843.9ED08C40A89@trevor.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Rob Landley <rob@landley.net>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: Grant Likely <grant.likely@linaro.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:58983 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbaBEOfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 09:35:40 -0500
Received: by mail-lb0-f169.google.com with SMTP id q8so388042lbi.0
        for <netdev@vger.kernel.org>; Wed, 05 Feb 2014 06:35:39 -0800 (PST)
In-Reply-To: <20140205120843.9ED08C40A89@trevor.secretlab.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02/05/2014 03:08 PM, Grant Likely wrote:

>>>>>>>>>       I'm afraid that's too late, it has spread very far, so that
>>>>>>>>> of_get_phy_mode() handles that property, not "phy-connection-type".

>>>>>>>> Uggg, I guess this is a case of a defacto standard then if the kernel
>>>>>>>> doesn't even support it.

>>>>>>> Maybe I forgot to CC you on patch sent to Grant only, I sent a patch a
>>>>>>> while ago for of_get_phy_mode() to look for both "phy-mode" and
>>>>>>> "phy-connection-type" since the former has been a Linux invention, but
>>>>>>> the latter is ePAPR specified.

>>>>>> Here is a link to the actual patch in question, not sure which tree
>>>>>> Grant applied it to though:

>>>>>> http://lkml.indiana.edu/hypermail/linux/kernel/1311.2/00048.html

>>>>>       It's not the patch mail, it's Grant's "applied" reply, patch is mangled in
>>>>> this reply, and I couldn't follow the thread. Here's the actual patch mail:

>>>>> http://marc.info/?l=devicetree&m=138449662807254

>>>>       Florian, I didn't find this patch in Grant's official tree, so maybe you
>>>> should ask him where is the patch already?

>>> Sorry, I accidentally dropped it. It will be in the next merge window.

>>      Already saw it, thanks. Would that it was in 3.14 instead of course, so
>> that I could use "phy-connection-type" in my binding...

> Is 3.14 broken because of missing the patch? If so I'll get it merged as
 > a bug fix.

    No, it's not. I could have used "phy-connection-type" in my binding 
destined for 3.15 and document it as a preferred property as well.

> g.

WBR, Sergei
