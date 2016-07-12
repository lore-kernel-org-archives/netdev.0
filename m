From: Jorge Alberto Garcia <jorge.garcia.gonzalez@gmail.com>
Subject: Re: ethtool TODO list - additional info
Date: Tue, 12 Jul 2016 13:04:52 -0500
Message-ID: <CAPfrtUcAuu5t7xQ-F4d-+AAbSByOzD7aBa_+UsE_xoXRdxEuoA@mail.gmail.com>
References: <CAPfrtUew6TKRMhoBfQ6MjxrCOsiQTYmM-2b20961LyRcLMOSZw@mail.gmail.com>
 <20160712175558.GB1799@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	netdev <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:38790 "EHLO
	mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbcGLSFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 14:05:32 -0400
Received: by mail-it0-f43.google.com with SMTP id h190so22737464ith.1
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 11:05:32 -0700 (PDT)
In-Reply-To: <20160712175558.GB1799@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2016 at 12:55 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Jul 05, 2016 at 05:37:42PM CEST, jorge.garcia.gonzalez@gmail.com wrote:
>>Hi !
>>
>>Some days ago, Jiri Pirko was talking about some next steps to
>>implement for ethtool.
>>
>> I haven't seen any follow up since ethtool's maintainer change. Can we have
>>additional details about these ?
>>
>>- libethtool - API
>>- generic netlink
>
> Yep, exactly, no reply. Apparently nobody really want to do any initiative
> here, and I'm lacking time to do it :(
>

That's fine,  I already got  a git repo, I'm trying to understand what
'use generic netlink' means.

This is a piece of what grep got me on iproute git repo (I'm still
trying to understand)
grep -i netlink -r iproute2/
iproute2/bridge/mdb.c:#include "libnetlink.h"
iproute2/bridge/vlan.c:#include "libnetlink.h"
...
..



>
>
>>- sub commands syntax
>>- TODO/bugzilla
>>
>>
>>On Mon, Jul 4, 2016 at 9:24 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>
>>>>> I was thinking of adding a TODO file to the repository, but it's really
>>>>> for the new maintainer to decide what to do.  So here's my list as a
>>>>> suggestion:
>>>>>
>>>>> * Add regression test coverage for all sub-commands with complex logic
>>>>>
>>>>> * Internationalise output and error messages
>>>>>
>>>>> * Build a libethtool that handles all the API quirks and fallbacks for
>>>>>   old kernel versions.  This might help people writing language
>>>>>   bindings or other utilities that use the ethtool API.
>>>>>
>>>>> * Provide a 'cleaned up' ethtool (under some other name) that has:
>>>>>   - More conventional sub-command syntax, i.e. no '-'/'--' prefix
>>>>>   - More consistent output formatting
>>>>
>>>>That seems like a reasonable start for a TODO list. I'll bet there
>>>>are a few people out there with other suggestions as well...?
>>>
>>> Before that, I would like to see ethtool migrate to use generic
>>> netlink. Then, the new tool would be needed anyway, should exist within
>>> iproute2 package and have similar command line syntax.
>>>
>>> I have some ideas about the gennetlink ethtool, have to find some time
>>> to implement some initial part of it.
