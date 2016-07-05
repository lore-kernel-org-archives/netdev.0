From: Jorge Alberto Garcia <jorge.garcia.gonzalez@gmail.com>
Subject: ethtool TODO list - additional info
Date: Tue, 5 Jul 2016 10:37:42 -0500
Message-ID: <CAPfrtUew6TKRMhoBfQ6MjxrCOsiQTYmM-2b20961LyRcLMOSZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	netdev <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:34105 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413AbcGEPiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 11:38:22 -0400
Received: by mail-oi0-f45.google.com with SMTP id s66so234059408oif.1
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 08:38:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi !

Some days ago, Jiri Pirko was talking about some next steps to
implement for ethtool.

 I haven't seen any follow up since ethtool's maintainer change. Can we have
additional details about these ?

- libethtool - API
- generic netlink
- sub commands syntax
- TODO/bugzilla


On Mon, Jul 4, 2016 at 9:24 AM, Jiri Pirko <jiri@resnulli.us> wrote:

>>> I was thinking of adding a TODO file to the repository, but it's really
>>> for the new maintainer to decide what to do.  So here's my list as a
>>> suggestion:
>>>
>>> * Add regression test coverage for all sub-commands with complex logic
>>>
>>> * Internationalise output and error messages
>>>
>>> * Build a libethtool that handles all the API quirks and fallbacks for
>>>   old kernel versions.  This might help people writing language
>>>   bindings or other utilities that use the ethtool API.
>>>
>>> * Provide a 'cleaned up' ethtool (under some other name) that has:
>>>   - More conventional sub-command syntax, i.e. no '-'/'--' prefix
>>>   - More consistent output formatting
>>
>>That seems like a reasonable start for a TODO list. I'll bet there
>>are a few people out there with other suggestions as well...?
>
> Before that, I would like to see ethtool migrate to use generic
> netlink. Then, the new tool would be needed anyway, should exist within
> iproute2 package and have similar command line syntax.
>
> I have some ideas about the gennetlink ethtool, have to find some time
> to implement some initial part of it.
