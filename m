From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 00/18] switchdev: spring cleanup
Date: Mon, 30 Mar 2015 08:00:35 -0700
Message-ID: <55196513.8080101@cumulusnetworks.com>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com> <20150330120025.GE2045@nanopsycho.orion> <20150330131049.GI1051@gospo>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, sfeldma@gmail.com,
	netdev@vger.kernel.org, linux@roeck-us.net, f.fainelli@gmail.com
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:32770 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752739AbbC3PAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 11:00:37 -0400
Received: by pacgg7 with SMTP id gg7so40310976pac.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 08:00:37 -0700 (PDT)
In-Reply-To: <20150330131049.GI1051@gospo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/30/15, 6:11 AM, Andy Gospodarek wrote:
> On Mon, Mar 30, 2015 at 02:00:25PM +0200, Jiri Pirko wrote:
>> Mon, Mar 30, 2015 at 10:40:18AM CEST, sfeldma@gmail.com wrote:
>>> From: Scott Feldman <sfeldma@gmail.com>
>>>
>>> The main theme of this patch set is to cleanup swdev in preparation for
>>> new features or fixes to be added soon.  We have a pretty good idea now how
>>> to handle stacked drivers in swdev, but there where some loose ends.  For
>>> example, if a set failed in the middle of walking the lower devs, we would
>>> leave the system in an undefined state...there was no way to recover back to
>>> the previous state.  Speaking of sets, also recognize a pattern that most
>>> swdev API accesses are gets or sets of port attributes, so go ahead and make
>>> port attr get/set the central swdev API, and convert everything that is
>>> set-ish/get-ish to this new API.
>>>
>>> Features/fixes that should follow from this cleanup:
>>>
>>> - solve the duplicate pkt forwarding issue
>>> - get/set bridge attrs, like ageing_time, from/to device
>>> - get/set more bridge port attrs from/to device
>>>
>>> There are some rename cleanups tagging along at the end, to give swdev
>>> consistent naming.
>> As you can see in the switchdev patch submission history, I originally
>> pushed this with "swdev_" previx. Turned out people did not like that
>> because "sw" can be easily misunderstood as "software".
> I agree with this.
>
agree. maybe just "switchdev_" will be better.
