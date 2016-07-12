From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: ethtool TODO list - additional info
Date: Tue, 12 Jul 2016 19:55:58 +0200
Message-ID: <20160712175558.GB1799@nanopsycho.orion>
References: <CAPfrtUew6TKRMhoBfQ6MjxrCOsiQTYmM-2b20961LyRcLMOSZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	netdev <netdev@vger.kernel.org>
To: Jorge Alberto Garcia <jorge.garcia.gonzalez@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:35553 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbcGLR4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 13:56:02 -0400
Received: by mail-wm0-f53.google.com with SMTP id f65so51161wmi.0
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 10:56:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAPfrtUew6TKRMhoBfQ6MjxrCOsiQTYmM-2b20961LyRcLMOSZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jul 05, 2016 at 05:37:42PM CEST, jorge.garcia.gonzalez@gmail.com wrote:
>Hi !
>
>Some days ago, Jiri Pirko was talking about some next steps to
>implement for ethtool.
>
> I haven't seen any follow up since ethtool's maintainer change. Can we have
>additional details about these ?
>
>- libethtool - API
>- generic netlink

Yep, exactly, no reply. Apparently nobody really want to do any initiative
here, and I'm lacking time to do it :(



>- sub commands syntax
>- TODO/bugzilla
>
>
>On Mon, Jul 4, 2016 at 9:24 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>
>>>> I was thinking of adding a TODO file to the repository, but it's really
>>>> for the new maintainer to decide what to do.  So here's my list as a
>>>> suggestion:
>>>>
>>>> * Add regression test coverage for all sub-commands with complex logic
>>>>
>>>> * Internationalise output and error messages
>>>>
>>>> * Build a libethtool that handles all the API quirks and fallbacks for
>>>>   old kernel versions.  This might help people writing language
>>>>   bindings or other utilities that use the ethtool API.
>>>>
>>>> * Provide a 'cleaned up' ethtool (under some other name) that has:
>>>>   - More conventional sub-command syntax, i.e. no '-'/'--' prefix
>>>>   - More consistent output formatting
>>>
>>>That seems like a reasonable start for a TODO list. I'll bet there
>>>are a few people out there with other suggestions as well...?
>>
>> Before that, I would like to see ethtool migrate to use generic
>> netlink. Then, the new tool would be needed anyway, should exist within
>> iproute2 package and have similar command line syntax.
>>
>> I have some ideas about the gennetlink ethtool, have to find some time
>> to implement some initial part of it.
