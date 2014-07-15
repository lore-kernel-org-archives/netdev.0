From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 2/2] bonding: make hard-coded defines
 configurable at build
Date: Tue, 15 Jul 2014 11:55:29 -0700
Message-ID: <CAADnVQKeFOhbZOSHtpodnWb6OXem79jjozHm=Qgzz8PyVTryRg@mail.gmail.com>
References: <1405419341-31510-1-git-send-email-vfalico@gmail.com>
	<1405419341-31510-3-git-send-email-vfalico@gmail.com>
	<CAADnVQJCNJVTBFkinNzo=1mSWEBhif3dOVnVvuievJxijtNb7w@mail.gmail.com>
	<20140715161802.GC5225@mikrodark.usersys.redhat.com>
	<CAADnVQJaUQsDF1--4ffnCUz=1Tw1Ox=kgUw3h1L1EnrDs0WQfw@mail.gmail.com>
	<20140715171139.GD5225@mikrodark.usersys.redhat.com>
	<CAADnVQKPJTHFGdCRtbQHLAg_NpDkKQ+8WVwfkic8KE+dQxZw2g@mail.gmail.com>
	<20140715175331.GA14109@mikrodark.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:40253 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932826AbaGOSzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 14:55:31 -0400
Received: by mail-la0-f50.google.com with SMTP id pv20so4581865lab.37
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 11:55:29 -0700 (PDT)
In-Reply-To: <20140715175331.GA14109@mikrodark.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2014 at 10:53 AM, Veaceslav Falico <vfalico@gmail.com> wrote:
> On Tue, Jul 15, 2014 at 10:33:25AM -0700, Alexei Starovoitov wrote:
> ..snip...
>
>> For 3 vlan case to be useful, first somebody needs to define a meaning
>> for it and real use case. I haven't seen one.
>
>
> You also haven't seen switches that support it, however juniper switches do
> support them, as a quick google shows. I can guess that cisco can also be
> made to support them.

I don't think juniper switches support them either.
Please send the link to the spec.
Protocol parsers in HW fail to parse beyond two, since behavior
is undefined and it's considered invalid packet.
I'm talking about broadcom/intel/cisco asics.
Generally speaking I think it's a mistake of linux stack to support
any nested level. Not too long ago we saw issues with broken hw
offloads for basic qinq. I won't be surprised if creating triple stacked
vlan devices actually breaks all sort of things.

> I'll happily drop any/all of these configs if I'd see a reason NOT to add
> them. Till now I haven't seen anything except "I don't know why should I
> use it", and that's not a valid reason to me, sorry.

correct. I don't see a good reason to change these defaults and you also
seem to acknowledge the same. To me it's a red flag when somebody
requests a feature without proper justification.
