From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH net] vxlan: fix incorrect RCO bit in VXLAN header
Date: Fri, 4 Dec 2015 09:13:28 -0800
Message-ID: <CALx6S34_MazNmhACWBnVYFzXT9qZPLy2CZK3BBhP8RJzoHYo4w@mail.gmail.com>
References: <67179e9385c71f7c377a7df345d445704f49dbbc.1449233631.git.jbenc@redhat.com>
	<CALx6S35_CbKfNpGJM6xsSgdkd25iekMCS3jwyG7_B5bCfeJhQw@mail.gmail.com>
	<20151204180610.51732e36@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:34777 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756335AbbLDRN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 12:13:29 -0500
Received: by ioir85 with SMTP id r85so122615013ioi.1
        for <netdev@vger.kernel.org>; Fri, 04 Dec 2015 09:13:28 -0800 (PST)
In-Reply-To: <20151204180610.51732e36@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 4, 2015 at 9:06 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Fri, 4 Dec 2015 08:43:59 -0800, Tom Herbert wrote:
>> What a mess VXLAN has become. There are no guidelines or order in
>> defining these reserved bits! If anyone is looking to do some work in
>> encapsulation please consider bringing up VXLAN-GPE/NSH in the stack,
>> hopefully that world will be better....
>
> I'm actually working right now on VXLAN-GPE implementation (and tons of
> cleanups in the vxlan code) which is the reason I noticed this bug.
>
That's awesome! One favor, can you make sure VXLAN-GPE works with IPv6
from the start. :-)

Also, I'll need to spin an I-D for RCO in VXLAN-GPE. Do you see any
reason to use a different bit for it?

Tom

>> Acked-by: Tom Herbert <tom@herbertland.com>
>
> Thanks. David, as this was submitted as RFC, should I resubmit?
> Provided that you're okay with the patch, of course; it changes the
> on-wire format which should not be taken lightly, even though the
> current behavior is incorrect.
>
>  Jiri
>
> --
> Jiri Benc
