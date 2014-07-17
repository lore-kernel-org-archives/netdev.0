From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: use dev->name in netdev_pr* when it's
 available
Date: Thu, 17 Jul 2014 16:01:58 +0200
Message-ID: <20140717140158.GA28357@mikrodark.usersys.redhat.com>
References: <1405596491-5881-1-git-send-email-vfalico@gmail.com>
 <1405596491-5881-2-git-send-email-vfalico@gmail.com>
 <CAG-2HqXhU5RHkMOyj9H2CboYJ1LNFnXzXC_QaAML8P1tihmahg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Tom Gundersen <teg@jklm.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:40855 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755170AbaGQOE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 10:04:57 -0400
Received: by mail-la0-f41.google.com with SMTP id s18so1802529lam.0
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 07:04:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAG-2HqXhU5RHkMOyj9H2CboYJ1LNFnXzXC_QaAML8P1tihmahg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2014 at 03:48:45PM +0200, Tom Gundersen wrote:
>On Thu, Jul 17, 2014 at 1:28 PM, Veaceslav Falico <vfalico@gmail.com> wrote:
>> e() returns dev->name only when the net_device is in
>> NETREG_REGISTERED state.
>>
>> However, dev->name is always populated on creation, so we can easily use
>> it. The only caveat is that the device still has a name of type "eth%d", in
>> which case we cannot use this name as it'll change in the nearest future,
>> thus return "unnamed net_device".
>
>There are also cases when the name is set to emptystring before being
>populated with the real name later on. You may want to check for that
>too.

Sure, it'd be easy enough.

Out of curiosity - can you point me to where it's an empty string?

I'll send v2 now.

Thank you!

>
>Cheers,
>
>Tom
