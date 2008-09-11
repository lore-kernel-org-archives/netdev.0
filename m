From: "Andrew Grover" <andy.grover@gmail.com>
Subject: Re: [PATCH] RDS: Add AF and PF defines for RDS sockets
Date: Thu, 11 Sep 2008 11:44:39 -0700
Message-ID: <c0a09e5c0809111144v7f7db03es963aa222147dc3a3@mail.gmail.com>
References: <75428E88-423C-492F-AE72-3157D968DC04@holtmann.org>
	 <20080825.212914.197506339.davem@davemloft.net>
	 <1219907200.7107.228.camel@pmac.infradead.org>
	 <20080828.002457.26700892.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, marcel@holtmann.org, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:38711 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752661AbYIKSol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 14:44:41 -0400
Received: by gxk9 with SMTP id 9so17198579gxk.13
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 11:44:40 -0700 (PDT)
In-Reply-To: <20080828.002457.26700892.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(reviving an old thread, new comments at bottom)

On Thu, Aug 28, 2008 at 12:24 AM, David Miller <davem@davemloft.net> wrote:
> From: David Woodhouse <dwmw2@infradead.org>
> Date: Thu, 28 Aug 2008 08:06:40 +0100
>
>> On Mon, 2008-08-25 at 21:29 -0700, David Miller wrote:
>> > From: Marcel Holtmann <marcel@holtmann.org>
>> > Date: Tue, 26 Aug 2008 06:16:28 +0200
>> >
>> > > and where is the protocol? Adding new constants without posting the
>> > > implementation normally doesn't fly anymore.
>> >
>> > That's correct :)
>>
>> That's kind of unfortunate, and leads to the problems we have with
>> compatibility for AF_ISDN, where userspace built for the _older_
>> versions has a different value.
>>
>> Is there really any harm in reserving it up-front?
>
> If you're commiting a userspace to a kernel component
> that hasn't been blessed upstream yet, you're already
> up the creek without a paddle.

The RDS protocol is already in production use by Oracle, and has been
in the OFED distribution for a long time. It's under active
development, and we'll be submitting it soon for mainline.

So userspace is already committed to a kernel component that isn't in
mainline, and we *are* up a creek a little bit. User code has to do
some hacky things to determine RDS's protocol number (it's variable).
The sooner we get an actual number allocated, the sooner userspace can
start using it, and start the clock ticking on when it can remove the
old variable protocol num hack.

Basically: we're gonna submit the code. Who knows how many rounds of
reviews it will take before it goes in, but we're committed to getting
it in. We just want a number now so userspace can start doing things
correctly right away.

Let me know and I can repost the patch.

Regards -- Andy
