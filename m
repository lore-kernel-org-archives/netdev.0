From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: e1000e NVM mutex contention warnings
Date: Thu, 23 Apr 2009 16:24:13 -0700
Message-ID: <9929d2390904231624g5fab1231l57815c2311d07acb@mail.gmail.com>
References: <1240147024.3384.20.camel@deadeye.i.decadent.org.uk>
	 <F169D4F5E1F1974DBFAFABF47F60C10A29F7BE99@orsmsx507.amr.corp.intel.com>
	 <1240528484.3605.39.camel@deadeye.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Graham, David" <david.graham@intel.com>,
	"524699@bugs.debian.org" <524699@bugs.debian.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:3212 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760557AbZDWXYO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 19:24:14 -0400
Received: by yx-out-2324.google.com with SMTP id 3so495115yxj.1
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2009 16:24:13 -0700 (PDT)
In-Reply-To: <1240528484.3605.39.camel@deadeye.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 23, 2009 at 4:14 PM, Ben Hutchings <ben@decadent.org.uk> wr=
ote:
> On Thu, 2009-04-23 at 15:15 -0700, Brandeburg, Jesse wrote:
>> Ben Hutchings wrote:
>> > What's your plan for collecting information about NVM mutex conten=
tion
>> > and when do you intend to remove the warnings? =C2=A0I have to say=
 I find
>> > this way of testing very user-unfriendly and would like to see it =
gone
>> > as soon as possible.
>>
>> Hi Ben,
>>
>> checking linus' tree and davem's current net-2.6 tree shows that the
>> code was removed as of commit: 0a834a36ac92375cd82d9e4fe4f571e257997=
d6a
>>
>> it was put in 2/14/2009, and was included in 2.6.30-rc1 by linus.
>
> Thanks. =C2=A0I had a look but somehow missed that this was already o=
n the
> way out in 2.6.30.
>
>> are you suggesting that we maybe try to push to -stable too?
>
> If you now have the information you need about contention, then it se=
ems
> to me that it would be worthwhile to remove the unnecessary warnings.
> If you don't want to submit a stable update then I can patch it out i=
n
> the Debian kernel package.
>
> Ben.

I am fine with pushing this patch to -stable.

--=20
Cheers,
Jeff
