From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] ss: Use rtnl_dump_filter in handle_netlink_request
Date: Thu, 4 Dec 2014 00:15:54 +0200
Message-ID: <CAMw6YJ+W0KCvGrfij990+BU2EsW6E4SEWJRsrRgk=vnq-okjzQ@mail.gmail.com>
References: <1417531984-3522-1-git-send-email-vadim4j@gmail.com>
	<20141203092129.49f16769@urahara>
	<20141203172010.GA8639@angus-think.wlc.globallogic.com>
	<20141203095123.40429f4c@urahara>
	<20141203174506.GA12511@angus-think.wlc.globallogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:38166 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334AbaLCWPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 17:15:55 -0500
Received: by mail-wg0-f48.google.com with SMTP id y19so21134516wgg.35
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 14:15:54 -0800 (PST)
In-Reply-To: <20141203174506.GA12511@angus-think.wlc.globallogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I established some simple OpenVPN connection (at least by the logs and
ss I see that peer is connected), but
I dont get any errors with ss.

So can you please provide some more info how did you tested this patch
? I am surprised that this is caused only
by these changes ...

On Wed, Dec 3, 2014 at 7:45 PM,  <vadim4j@gmail.com> wrote:
> On Wed, Dec 03, 2014 at 09:51:23AM -0800, Stephen Hemminger wrote:
>> On Wed, 3 Dec 2014 19:20:10 +0200
>> vadim4j@gmail.com wrote:
>>
>> > On Wed, Dec 03, 2014 at 09:21:29AM -0800, Stephen Hemminger wrote:
>> > > On Tue,  2 Dec 2014 16:53:04 +0200
>> > > Vadim Kochan <vadim4j@gmail.com> wrote:
>> > >
>> > > > Replaced handling netlink messages by rtnl_dump_filter
>> > > > from lib/libnetlink.c, also:
>> > > >
>> > > >     - removed unused dump_fp arg;
>> > > >     - added MAGIC_SEQ #define for 123456 seq id
>> > > >
>> > > > Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
>> > >
>> > > This doesn't work correctly.
>> > >
>> > > Simple test
>> > >   $ misc/ss >/dev/null
>> > > RTNETLINK answers: No such file or directory
>> > > RTNETLINK answers: No such file or directory
>> > > RTNETLINK answers: No such file or directory
>> >
>> > Just tried, I did not get such errors.
>>
>> I have OpenVPN running.
>
> Hm, it is reproduced only with this patch ?
> If so I will try to setup OpenVPN ... can't imagine how it can be
> related ...
