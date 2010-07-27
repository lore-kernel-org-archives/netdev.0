From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH] Driver-core: Fix bluetooth network device rename
	regression
Date: Tue, 27 Jul 2010 17:32:24 +0200
Message-ID: <AANLkTim2i8LiAaDPUyJqKtyhHC2ufuxZNKYMoVYKz_eZ@mail.gmail.com>
References: <AANLkTil3Q1Vobw48AvStl9gphaJcyUGlt6ZnMLanDMVn@mail.gmail.com>
	<1279822828.12439.24.camel@jlt3.sipsolutions.net> <20100722182827.GA12821@suse.de>
	<1279823801.12439.31.camel@jlt3.sipsolutions.net> <20100722185449.GB528@suse.de>
	<m1eievugon.fsf@fess.ebiederm.org> <20100726180941.GB4883@kroah.com>
	<AANLkTincg-0-h1aqW4A=z6A+HTbOfkCCWKDD18ZUEGSn@mail.gmail.com>
	<20100727134904.GA4994@kroah.com> <1280239190.3755.4.camel@jlt3.sipsolutions.net>
	<20100727150921.GD5803@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	netdev <netdev@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:54733 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753580Ab0G0Pcj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 11:32:39 -0400
Received: by pxi14 with SMTP id 14so494718pxi.19
        for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 08:32:39 -0700 (PDT)
In-Reply-To: <20100727150921.GD5803@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 27, 2010 at 17:09, Greg KH <greg@kroah.com> wrote:
> On Tue, Jul 27, 2010 at 03:59:50PM +0200, Johannes Berg wrote:
>> On Tue, 2010-07-27 at 06:49 -0700, Greg KH wrote:
>>
>> > And Eric, where are you working on the "real" patches to solve the
>> > problems of the bnet and wireless driver problems so we can remove=
 this
>> > check from the driver core as soon as possible? =C2=A0Any idea whe=
n they will
>> > be done?
>>
>> They'll be done as soon as the driver core offers the required
>> functionality, which we discussed elsewhere in this thread.
>
> {sigh}
>
> Kay provided a solution for this a number of times already. =C2=A0Wha=
t, are
> you really going to make him type it up _again_? =C2=A0That's just co=
mpletly
> unfair to him.

Sure, I still offer any needed help, if there are new requirements now
that need core changes. But hey, they will not land magically, if
nobody is working on it. And "as soon as the core offers" is not how
we make new features work on Linux. The people who add new features,
which uncover old bugs, need to fix the old bugs instead of papering
them over, like it happened here.

> And note, Eric, this was and is, completely due to your changes, so I=
 am
> holding you responsible for fixing it correctly. =C2=A0Please do so.

I guess faking a 'bluetooth renaming regression', which never existed,
which wasn't even known to the bluetooth maintainers, was just much
easier. :)

Kay
