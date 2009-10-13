From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: Moving drivers into staging (was Re: [GIT PULL] SCSI fixes for
	2.6.32-rc3)
Date: Tue, 13 Oct 2009 11:08:15 -0700
Message-ID: <43e72e890910131108m789110b4hc35e25601ad67bb7@mail.gmail.com>
References: <alpine.LFD.2.01.0910081255510.3432@localhost.localdomain>
	<alpine.LFD.2.01.0910081410400.3432@localhost.localdomain>
	<20091009091538.GA4154@elte.hu> <1255097287.2934.21.camel@localhost.localdomain>
	<20091012130652.GB25464@elte.hu> <1255357148.2850.91.camel@localhost.localdomain>
	<20091012145453.GD4565@elte.hu> <20091012150911.GB1656@suse.de>
	<20091012154244.GA13323@elte.hu> <20091012232429.GA24254@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>,
	James Bottomley <James.Bottomley@suse.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Theodore Tso <tytso@mit.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Jing Huang <huangj@brocade.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f180.google.com ([209.85.223.180]:53701 "EHLO
	mail-iw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760842AbZJMSJL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 14:09:11 -0400
In-Reply-To: <20091012232429.GA24254@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 12, 2009 at 4:24 PM, Greg KH <gregkh@suse.de> wrote:
> On Mon, Oct 12, 2009 at 05:42:44PM +0200, Ingo Molnar wrote:
>> Hm, i think i even gave drivers/staging/ its name?
>
> Yes you did, and I appreciate it :)
>
>> > [...] It seems that I'm the only one that has the ability to drop
>> > drivers out of the kernel tree, which is a funny situation :)
>>
>> You are the only one who has the ability to send a warning shot towa=
rds
>> drivers _without hurting users_, and by moving it into the focus of =
a
>> team of cleanup oriented developers.
>>
>> I think that's an important distinction ;-)
>
> Good point.
>
>> > In thinking about this a lot more, I don't really mind it. =C2=A0I=
f people
>> > want to push stuff out of "real" places in the kernel, into
>> > drivers/staging/ and give the original authors and maintainers not=
ice
>> > about what is going on, _and_ provide a TODO file for what needs t=
o
>> > happen to get the code back into the main portion of the kernel tr=
ee,
>> > then I'll be happy to help out with this and manage it.
>> >
>> > I think a 6-9 month window (basically 3 kernel releases) should be
>> > sufficient time to have a driver that has been in drivers/staging/=
 be
>> > cleaned up enough to move back into the main kernel tree. =C2=A0If=
 not, it
>> > could be easily dropped.
>> >
>> > Any objections to this?
>>
>> Sounds excellent to me!
>
> Great, I'll await the patches to move stuff to drivers/staging/ now.
>
> Wireless developers, warm up your editors :)

OK -- prism54 seems like a good candidate, instead of removing it
completely as I originally outlined on the feature removal schedule.
Do we have a file to give notices to move drivers to staging because
they are old as with the feature removal schedule? The more visible
these things become the better it is for users.

  Luis
