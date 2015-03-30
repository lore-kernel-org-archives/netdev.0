From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 02/18] switchdev: flesh out get/set attr ops
Date: Mon, 30 Mar 2015 14:00:20 -0700
Message-ID: <CAE4R7bBWornrgtOan0U0tuK06XWgLnsh8hbQLjNitrVR87JWnw@mail.gmail.com>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
	<1427704836-8776-3-git-send-email-sfeldma@gmail.com>
	<E4CD12F19ABA0C4D8729E087A761DC35067FA6FE@ORSMSX101.amr.corp.intel.com>
	<20150330204612.GA10481@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Arad, Ronen" <ronen.arad@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"linux@roeck-us.net" <linux@roeck-us.net>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:33019 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753237AbbC3VAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 17:00:21 -0400
Received: by qgfa8 with SMTP id a8so193742332qgf.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 14:00:20 -0700 (PDT)
In-Reply-To: <20150330204612.GA10481@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 30, 2015 at 1:46 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Mon, Mar 30, 2015 at 08:32:09PM CEST, ronen.arad@intel.com wrote:
>>
>>
>>>-----Original Message-----
>>>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>>>Behalf Of sfeldma@gmail.com
>>>Sent: Monday, March 30, 2015 1:40 AM
>>>To: netdev@vger.kernel.org
>>>Cc: jiri@resnulli.us; roopa@cumulusnetworks.com; linux@roeck-us.net;
>>>f.fainelli@gmail.com
>>>Subject: [PATCH net-next 02/18] switchdev: flesh out get/set attr ops
>>>
>>>From: Scott Feldman <sfeldma@gmail.com>
>>>

[cut]

>>>+     err = _swdev_port_attr_set(dev, attr);
>>>+     if (err && !get_err && !(attr->flags & SWDEV_ATTR_F_NO_RECOVER))
>>>+             /* Some err on set: revert to previous value */
>>>+             _swdev_port_attr_set(dev, &prev);
>>
>>Could revering to previous value fail?
>
> I believe that it certainly could
>
>>Should such failure be logged?
>
> That is a good point.

I'll add a log msg on revert set failure, good suggestion.


> Also, looking at the function name, seems nicer to me to use "__"
> instead of "_" as a function prefix. Not sure if that is some rule
> somewhere.

Sure.  I'm not sure what the rule is either.  I seems to remember
about using "_" prefix for funcs called under lock, or something like
that.  I'll change it to "__".
