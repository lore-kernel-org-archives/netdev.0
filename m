From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] DT: net: document Ethernet bindings in one place
Date: Tue, 21 Jan 2014 12:05:25 -0800
Message-ID: <CAGVrzcb0dfw1orZzUt5-YkShOg-HNbUYvvo2vfmsZUZXy1Aqfg@mail.gmail.com>
References: <201401180405.07859.sergei.shtylyov@cogentembedded.com>
 <CAL_Jsq+oa9P=rh+p-dMZyGP8TcmpX7bTnMU0ynLvFxjxFDYbRg@mail.gmail.com>
 <52DD98F7.4090202@cogentembedded.com> <CAL_JsqJXbF1-PcPHR2VP+Vi9A1aWizdsG_r3kDvRt3itXDhCGQ@mail.gmail.com>
 <CAGVrzcb3X3soJNJCE5+YSpQrr+EdycCRFkptPvBCgFg4CbGJ4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev <netdev@vger.kernel.org>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Rob Landley <rob@landley.net>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	Grant Likely <grant.likely@linaro.org>
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:65116 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbaAUUGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 15:06:06 -0500
In-Reply-To: <CAGVrzcb3X3soJNJCE5+YSpQrr+EdycCRFkptPvBCgFg4CbGJ4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014/1/21 Florian Fainelli <f.fainelli@gmail.com>:
>>>    I'm afraid that's too late, it has spread very far, so that
>>> of_get_phy_mode() handles that property, not "phy-connection-type".
>>
>> Uggg, I guess this is a case of a defacto standard then if the kernel
>> doesn't even support it.
>
> Maybe I forgot to CC you on patch sent to Grant only, I sent a patch a
> while ago for of_get_phy_mode() to look for both "phy-mode" and
> "phy-connection-type" since the former has been a Linux invention, but
> the latter is ePAPR specified.

Here is a link to the actual patch in question, not sure which tree
Grant applied it to though:

http://lkml.indiana.edu/hypermail/linux/kernel/1311.2/00048.html

>
>>
>>>>> +- phy-connection-type: the same as "phy-mode" property (but described in
>>>>> ePAPR);
>>>>> +- phy-handle: phandle, specifies a reference to a node representing a
>>>>> PHY
>>>>> +  device (this property is described in ePAPR);
>>>>> +- phy: the same as "phy-handle" property (but actually ad-hoc one).
>>>
>>>
>>>> Mark this as deprecated in favor of phy-handle.
>>>
>>>
>>>    Here situation is more optimistic. Quite many drivers still use
>>> "phy-handle", though some use even more exotic props I didn't document here.
>>
>> Perhaps flagging as "Not recommended for new bindings" would be nicer wording...
>
> Ok, so what's the deal here, can't we use phy-handle? There is
> currently no infrastructure in drivers/net/ or drivers/of/ to look for
> the "phy-handle" nor "phy" properties as phandles to fetch an Ethernet
> PHY device tree node. If we are to provide one common place where we
> want to do this, we will have to look for both properties, why can't
> we mandate the use of "phy-handle" since this is the ePAPR compliant
> one?
>
>>
>> Rob
>> --
>> To unsubscribe from this list: send the line "unsubscribe devicetree" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>
> --
> Florian



-- 
Florian
