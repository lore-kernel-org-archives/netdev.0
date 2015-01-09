From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 00/11] A flow API
Date: Fri, 09 Jan 2015 09:26:07 -0800
Message-ID: <54B00F2F.2090602@gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32> <CAJ3xEMjb+pG3TR+r0huNVSGkuPE9i7EZeHO4SQkcfm=WA6zMeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	simon.horman@netronome.com,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:61426 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756665AbbAIR0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 12:26:31 -0500
Received: by mail-ob0-f179.google.com with SMTP id va2so14107327obc.10
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 09:26:30 -0800 (PST)
In-Reply-To: <CAJ3xEMjb+pG3TR+r0huNVSGkuPE9i7EZeHO4SQkcfm=WA6zMeA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/2015 07:14 AM, Or Gerlitz wrote:
> On Wed, Dec 31, 2014 at 9:45 PM, John Fastabend
> <john.fastabend@gmail.com> wrote:
>> For some examples and maybe a bit more illustrative description I
>> posted a quickly typed up set of notes on github io pages. Here we
>> can show the description along with images produced by the flow tool
>> showing the pipeline. Once we settle a bit more on the API we should
>> probably do a clean up of this and other threads happening and commi=
t
>> something to the Documentation directory.
>>
>>   http://jrfastab.github.io/jekyll/update/2014/12/21/flow-api.html
>
> John, Going over your excellent tutorial, the distinction between
> action and operation isn=E2=80=99t clear... specifically, the paragra=
ph
> =E2=80=9CAlthough this gives us a list of actions we can perform on a=
 packet
> and a set of argument to give the action so we can use them it does
> not supply the operations performed on the packet=E2=80=9D is a bit v=
ague.
>
> Or.
>

Agreed that is a bit confusing. What I was trying to show is if two
hardware devices give you the same action but with different names
showing they are equivalent is not possible with the current API.
So either (a) you need to enforce every device names their actions
correctly or (b) provide a mechanism to describe the actions so we
can evaluate their equivalence.

Its actually worse then this what I want to eventually show is if
device A has support for a set of actions and device B has support
for another set. I want to be able to say things about the devices
like device A can support any action B can do but it may require
applying a 2 actions from A's collection of actions. (clear as mud?)
I'll try to clear it up in the documentation.

Thanks for looking it over.
=2EJohn

--=20
John Fastabend         Intel Corporation
