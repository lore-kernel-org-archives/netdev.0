From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC 0/5] Add NTF_EXT_AGED to control FDB ageing
 in SW or HW
Date: Sat, 21 Feb 2015 10:31:11 -0800
Message-ID: <54E8CEEF.2010200@cumulusnetworks.com>
References: <1424416195-19098-1-git-send-email-sfeldma@gmail.com> <54E76EFA.1050209@cumulusnetworks.com> <54E7876A.3060303@gmail.com> <20150221110359.GA2095@nanopsycho.orion> <FFEDCF9956066D4D97C463CC178C7F69F23378@SJEXCHMB06.corp.ad.broadcom.com> <20150221155002.GA2092@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Viswanath Bandaru <vbandaru@broadcom.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux@roeck-us.net" <linux@roeck-us.net>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"siva.mannem.lnx@gmail.com" <siva.mannem.lnx@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36424 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020AbbBUSbN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2015 13:31:13 -0500
Received: by pabkq14 with SMTP id kq14so16463541pab.3
        for <netdev@vger.kernel.org>; Sat, 21 Feb 2015 10:31:13 -0800 (PST)
In-Reply-To: <20150221155002.GA2092@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/21/15, 7:50 AM, Jiri Pirko wrote:
> Sat, Feb 21, 2015 at 12:29:38PM CET, vbandaru@broadcom.com wrote:
>>> -----Original Message-----
>>>> I agree, in fact, most of the HW I have access to only has a global age
>>>> timer configuration knob. Is this configurable on a per-port basis for
>>>> higher end switches, or even maybe per-FDB entry?
>>> I'm currently not aware of any hw which does not have global age timer.
>>> But I believe that they will appear. The model that we have now, to
>>> propagate aging setting of bridge down is more general and should be ok.
>>>
>>> Drivers should probably take care of multi bridge setup with different aging
>>> setup. Maybe to find minimal time and print a warning?
>>>
>> Setting up the minimal time in such a scenario is good.
>>
>> Should we also consider the possibility bridges containing ports from different  devices (and therefore different drivers) ? If that is a possibility, I think the bridge module should take responsibility of finding out the minimal time to pushing to all involved drivers.
> It is certainly possible to bridge ports from multiple switch devices.
> But that should not be a problem, because 1 bridge has 1 aging setup
> which will be passed to all port drivers.
>
> I believe that the only case which need to be resolved is multiple
> bridges over single switch device. And I believe that it should be
> handled in drivers because only drivers know what the hw is capable of
> (if it supports aging setup per port/bridge/global).
>
>>
I agree.
