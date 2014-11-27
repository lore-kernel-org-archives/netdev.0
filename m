From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v3 04/17] net: introduce generic switch devices support
Date: Wed, 26 Nov 2014 19:58:12 -1000
Message-ID: <CAE4R7bC2GTOAHm6uN9CboQ8HRFQ0+-7yoK+XF3wUysA9Sbo=gw@mail.gmail.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
	<1416911328-10979-5-git-send-email-jiri@resnulli.us>
	<5474A567.4040401@mojatatu.com>
	<20141125164954.GJ1971@nanopsycho.orion>
	<5474B795.3080204@mojatatu.com>
	<20141125215402.GA3912@casper.infradead.org>
	<54754A10.6020601@mojatatu.com>
	<CAE4R7bCYwWt5cem5_v8Y0jOSz5ER5_33bMRE2xkTPOqYvM6dUg@mail.gmail.com>
	<5475BB53.3070200@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:61277 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751040AbaK0F6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 00:58:13 -0500
Received: by mail-wg0-f54.google.com with SMTP id l2so5528063wgh.13
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 21:58:12 -0800 (PST)
In-Reply-To: <5475BB53.3070200@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 26, 2014 at 1:36 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 11/25/14 23:18, Scott Feldman wrote:
>>
>> On Tue, Nov 25, 2014 at 5:33 PM, Jamal Hadi Salim <jhs@mojatatu.com>
>> wrote:
>
>
>>
>> You have a pointer to the kernel driver for that HW?
>
>
> I wasnt sure if that was a passive aggressive move there to
> question what i am claiming?(Only Canadians are allowed to be
> passive aggressive Scott). To answer your question, no
> code currently littered with vendor SDK unfortunately (as you
> would know!).

Drats, I was hoping there might be Open Source here.  I'm actually not
familiar with Netronome offerings.  I went to their web page and all
their Docs downloads require registration, so I should have guessed
same-old-same-old.  But you teased us with it, so I thought I would
ask.  Sorry for the trouble XOXOXOXO.  I'm not Canadian, as far as I
know.

> But hopefully if we get these changes in correctly it would
> not be hard to show the driver working fully in the kernel.
> There are definetely a few other pieces of hardware that are
> making me come back here and invest time and effort in these
> long discussions.

You have access to the inside scope.  We don't.  Ok, I don't.  We
(think we) know what the traditional L2/L3 and OVS-style flow stuff
looks like, but you know more, but you can't show us in code so it's
frustrating.  Not your fault.  Just continue to guide us and give some
disclaimer when we're your close to some proprietary knowledge, but it
is relevant to the discussion.


>> Can you show how
>> you're using Linux tc netlink msg in kernel to program HW?  I'd like
>> to see the in-kernel API.
>>
>
> Lets do the L2/port thing first. But yes, I am using Linux tc in
> kernel.
>
> cheers,
> jamal
