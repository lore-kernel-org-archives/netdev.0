From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [RFC][PATCH] Fix another namespace issue with devices assigned to
	classes
Date: Mon, 14 Jun 2010 11:13:39 +0200
Message-ID: <AANLkTil4IvOiDHnLwAaeseEPVgYp-EF5TK1HfHitY3-H@mail.gmail.com>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	<20100602154608.GB12361@kroah.com> <1275493693.3915.12.camel@jlt3.sipsolutions.net>
	<m1ljaxxvcj.fsf@fess.ebiederm.org> <1275495677.3915.16.camel@jlt3.sipsolutions.net>
	<m14ohlxu51.fsf@fess.ebiederm.org> <1275498007.3915.20.camel@jlt3.sipsolutions.net>
	<m1ocftwdp7.fsf@fess.ebiederm.org> <1275501157.3915.22.camel@jlt3.sipsolutions.net>
	<m1y6exux6x.fsf@fess.ebiederm.org> <1275506732.3915.41.camel@jlt3.sipsolutions.net>
	<m16321t4ke.fsf@fess.ebiederm.org> <m17hmhrl6v.fsf_-_@fess.ebiederm.org>
	<1275634452.5189.1.camel@jlt3.sipsolutions.net> <AANLkTingSwM7e8ldyT1FplF5WCHBsCBCwNkb5ZPHe6hB@mail.gmail.com>
	<1275640113.9953.8.camel@jlt3.sipsolutions.net> <AANLkTin6ub4k4QYSMnGLRw7lxQaz23Xmo2GQC1RrUf-X@mail.gmail.com>
	<1275829701.3615.54.camel@jlt3.sipsolutions.net> <AANLkTinUAR2gkY7ipgXKy-pMHcmLuouEeyXxnP97U_7N@mail.gmail.com>
	<1275903773.29978.1.camel@jlt3.sipsolutions.net> <AANLkTin_qjU0-xXfMDYeYWRd0BmvT4OIdK4S_GQ3ZYUi@mail.gmail.com>
	<1275905686.29978.3.camel@jlt3.sipsolutions.net> <AANLkTikMDvpEzrtFVue8gStudKONxuQmVx9B2w1JM1vO@mail.gmail.com>
	<1275910905.29978.7.camel@jlt3.sipsolutions.net> <1275913563.1823.1.camel@yio.site>
	<1275914205.29978.10.camel@jlt3.sipsolutions.net> <AANLkTilqB2sAyfBTLhYT_a2_TySGay4FFG6SGJUZ1o_4@mail.gmail.com>
	<1275989260.3706.115.camel@jlt3.sipsolutions.net> <AANLkTinMauFsJTKS3eT-pT44KQ8PSf3HJLS8CZIeHmxP@mail.gmail.com>
	<1275990325.3706.116.camel@jlt3.sipsolutions.net> <1275998127.1899.38.camel@yio.site>
	<1275998603.3706.118.camel@jlt3.sipsolutions.net> <AANLkTinev96yxFCFSdDdT89jjgYR4ChUCMU2-aSj8kkh@mail.gmail.com>
	<1276005970.3706.132.camel@jlt3.sipsolutions.net> <AANLkTikB0Amzi61JLxdY5HL-2s_nbYo3JH8vXooXzHdQ@mail.gmail.com>
	<1276007174.3706.133.camel@jlt3.sipsolutions.net> <AANLkTikNEzJHPrOUK6DKMoWvcblTBInaIhVbk96OtZxe@mail.gmail.com>
	<1276009590.3706.135.camel@jlt3.sipsolutions.net> <AANLkTimSqF4D4jPj-HzOjl1vxjf2T7YvlGdR6zcJZ9Pp@mail.gmail.com>
	<1276014816.3706.137.camel@jlt3.sipsolutions.net> <AANLkTilUd2Bp1h4SzlW5f5KevoRM-os_fQrivLHbZyKY@mail.gmail.com>
	<1276250151.3640.11.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:58450 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123Ab0FNJNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 05:13:55 -0400
Received: by iwn9 with SMTP id 9so3090365iwn.19
        for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 02:13:55 -0700 (PDT)
In-Reply-To: <1276250151.3640.11.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 11, 2010 at 11:55, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Tue, 2010-06-08 at 18:39 +0200, Kay Sievers wrote:
>
>> That all works if you have two modules, like almost all buses have.
>> That's what I meant, that we need to add stuff to the core to be able
>> to cleanup bus devices internally too, if we use everything in a
>> single module, which is also supposed to cleanup on unload, like the
>> network devices like to do.
>
> Or some "wait for bus to be cleaned up" we can call in the module exit
> maybe?

That would block the rmmod process until the resources are cleaned up,
wouldn't it?

The network devices can do this because the cleanup code is always
compiled-in, for a module cleaning up itself, this is kind of
complicated, isn't it?

Kay
