From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 11/18] switchdev: remove old netdev_switch_port_bridge_setlink
Date: Wed, 1 Apr 2015 10:56:38 -0700
Message-ID: <CAE4R7bAK83dxypmCq294gE-msCsi2ViV2qET2oQNoUP3wP4nwA@mail.gmail.com>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
	<1427704836-8776-12-git-send-email-sfeldma@gmail.com>
	<55194E63.5010100@cumulusnetworks.com>
	<CAE4R7bBWby3tDdzV+Hwvc_bzB3E-zNoHUQUX8OfF205Vyw-77g@mail.gmail.com>
	<E4CD12F19ABA0C4D8729E087A761DC35067FA7D3@ORSMSX101.amr.corp.intel.com>
	<CAE4R7bA4t-5P58jeK1NVAzM1fdk72o9UJRD8w+ByxKAtbp7b8A@mail.gmail.com>
	<E4CD12F19ABA0C4D8729E087A761DC35067FA9F0@ORSMSX101.amr.corp.intel.com>
	<20150331055235.GB1994@nanopsycho.orion>
	<E4CD12F19ABA0C4D8729E087A761DC35067FB3E2@ORSMSX101.amr.corp.intel.com>
	<20150331215245.GA6515@nanopsycho.orion>
	<E4CD12F19ABA0C4D8729E087A761DC35067FB536@ORSMSX101.amr.corp.intel.com>
	<CAE4R7bCeRxP2Kg_4jg4v6m6S+3NFpMcxO4vC-WeDG48GPkCtuw@mail.gmail.com>
	<551BDE8F.9040907@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Arad, Ronen" <ronen.arad@intel.com>,
	Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	roopa <roopa@cumulusnetworks.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:34244 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbbDAR4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 13:56:39 -0400
Received: by qgep97 with SMTP id p97so49473771qge.1
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 10:56:38 -0700 (PDT)
In-Reply-To: <551BDE8F.9040907@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 1, 2015 at 5:03 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 03/31/15 22:38, Scott Feldman wrote:
>
>>
>> It sounds like vendor extensions need to be supported someway,
>> someday.
>
>
>
> I agree. This is one of those impendance mismatch things. There are
> scenarios where the feature may not be generic enough. But whatever
> feature it is - eventually we should get it back into mainstream.
> The danger of backdoors that Jiri alludes to is there.
>
>
>> Maybe let's table vendor extensions for the time being and
>> continue our focus on shared infrastructure: the things we know are
>> common for all vendors.  We still have a lot of work just getting the
>> common bits working.  Then we can take additional features one at a
>> time and see if they're shared or vendor-specific.  In the meantime,
>> there are always back doors such as genl for vendor to use; there is
>> nothing preventing that.
>>
>
> And now i disagree. Did you read the back of your netdev tshirt? Quote:
> ---
> I also don't buy the argument that "people can put arbitrary changes
> into their kernel to do stuff like that".
> ---
>
> Vendors can do whatever they want. We just should not be aiding them to
> put proprietary shit. I want to stop coding around SDKs. Help me.

I'm not sure what we're disagreeing on...I thought I said the same
thing.  I just want to defer the vendor extension discussion for now
and refocus on common stuff.  Trust me, there is no one on the planet
that wants to stop coding around the SDKs more than myself.

-scott
