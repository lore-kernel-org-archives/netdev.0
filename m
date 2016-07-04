From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: ethtool needs a new maintainer
Date: Mon, 4 Jul 2016 16:24:55 +0200
Message-ID: <20160704142455.GH2325@nanopsycho.orion>
References: <1466956772.2551.6.camel@decadent.org.uk>
 <1466957501.2551.17.camel@decadent.org.uk>
 <20160627135146.GB6864@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <ben@decadent.org.uk>,
	netdev <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36785 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbcGDOY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 10:24:59 -0400
Received: by mail-wm0-f41.google.com with SMTP id f126so105720852wma.1
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2016 07:24:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160627135146.GB6864@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jun 27, 2016 at 03:51:47PM CEST, linville@tuxdriver.com wrote:
>On Sun, Jun 26, 2016 at 06:11:41PM +0200, Ben Hutchings wrote:
>> I've become steadily less enthusiastic and less responsive as a
>> maintainer over the past year or so. =A0I no longer work on networki=
ng
>> regularly, so it takes a lot more time to get into the right state o=
f
>> mind to think about ethtool code, while I have other demands on my t=
ime
>> that tend to take priority.
>>=20
>> So, I would like to find a new maintainer to take over as soon as
>> possible. =A0Ideally the new maintainer would have previous contribu=
tions
>> to ethtool and an existing account on kernel.org so that they can pu=
sh
>> to the git repository and the home page. =A0But neither of those is
>> essential. =A0Please reply if you're interested.
>
>I would like to take this responsibility. My previous contributions
>to ethtool are meager, but I think my skills and interests are suited
>to the task.  Plus, I already have a kernel.org account... :-)
>
>> I was thinking of adding a TODO file to the repository, but it's rea=
lly
>> for the new maintainer to decide what to do. =A0So here's my list as=
 a
>> suggestion:
>>=20
>> * Add regression test coverage for all sub-commands with complex log=
ic
>>=20
>> * Internationalise output and error messages
>>=20
>> * Build a libethtool that handles all the API quirks and fallbacks f=
or
>> =A0 old kernel versions.=A0=A0This might help people writing languag=
e
>> =A0 bindings or other utilities that use the ethtool API.
>>=20
>> * Provide a 'cleaned up' ethtool (under some other name) that has:
>> =A0 - More conventional sub-command syntax, i.e. no '-'/'--' prefix
>> =A0 - More consistent output formatting
>
>That seems like a reasonable start for a TODO list. I'll bet there
>are a few people out there with other suggestions as well...?

Before that, I would like to see ethtool migrate to use generic
netlink. Then, the new tool would be needed anyway, should exist within
iproute2 package and have similar command line syntax.

I have some ideas about the gennetlink ethtool, have to find some time
to implement some initial part of it.
