From: Laurent Chavey <chavey@google.com>
Subject: Re: [PATCH v2 0/3] e1000e,igb,ixgbe: add registers etc. printout code
	just before resetting adapters
Date: Wed, 24 Feb 2010 11:36:14 -0800
Message-ID: <97949e3e1002241136q70f55c97rafd79c2a5a19349c@mail.gmail.com>
References: <4B593B74.2020601@jp.fujitsu.com> <alpine.WNT.2.00.1001221345580.6104@jbrandeb-desk1.amr.corp.intel.com>
	<4B5EC215.5090509@jp.fujitsu.com> <alpine.WNT.2.00.1002171043450.5328@jbrandeb-desk1.amr.corp.intel.com>
	<4B7E48F8.7010208@jp.fujitsu.com> <1266578456.25502.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Koki Sanagi <sanagi.koki@jp.fujitsu.com>,
	Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:10630 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757736Ab0BXTgj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 14:36:39 -0500
Received: from spaceape23.eur.corp.google.com (spaceape23.eur.corp.google.com [172.28.16.75])
	by smtp-out.google.com with ESMTP id o1OJaavt003665
	for <netdev@vger.kernel.org>; Wed, 24 Feb 2010 19:36:36 GMT
Received: from bwz20 (bwz20.prod.google.com [10.188.26.20])
	by spaceape23.eur.corp.google.com with ESMTP id o1OJaY9P010298
	for <netdev@vger.kernel.org>; Wed, 24 Feb 2010 11:36:35 -0800
Received: by bwz20 with SMTP id 20so2791461bwz.31
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2010 11:36:34 -0800 (PST)
In-Reply-To: <1266578456.25502.23.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Taku,

I like the idea of adding debugging support. While using syslog does pr=
ovide
a "easier" way to get the output out, I am wondering if it would be
worse the while
to try to add a generic debug interface (via ethtool / netlink) that
each driver would
then support.

If using syslog is the choosen way, then having the feature on by
default may not
be wanted.


On Fri, Feb 19, 2010 at 3:20 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> On Fri, 2010-02-19 at 01:16 -0700, Taku Izumi wrote:
>> Hi Jesse,
>>
>> > I have a counter proposal to make, here is a (incomplete) patch th=
at we
>> > use all the time to debug tx hangs. =A0This example is for e1000e.=
 =A0We are
>> > trying to avoid changes with other users' copyright to some of the=
 files
>> > in our drivers so that we can ship them under multiple license. =A0=
We would
>> > much prefer something like this to be used, can you review?
>>
>> =A0 I haven't understood yet about the reason we have to avoid chang=
ing some
>> =A0 files. Are there any files (header files?) we can't modify?
>>
>> Best regards,
>> Taku Izumi
>>
>
> To answer your question, no there are no files you can't submit patch=
es
> to. =A0We do have some common files which are used/shared amongst all=
 of
> our drivers which are used for initializing and/or bring up the
> hardware, so when a patch is submitted to our drivers which changes o=
ur
> "shared code" our first question is "Is this change necessary for all=
 of
> our drivers?" and if the answer is no, then we take a look at what
> changes can be made in the code which is not shared among our other
> drivers.
>
> --
> Cheers,
> Jeff
>
>
