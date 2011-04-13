From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: [Bugme-new] [Bug 32832] New: shutdown(2) does not fully shut down
 socket any more
Date: Wed, 13 Apr 2011 14:57:18 +0300
Message-ID: <BANLkTi=1wmQYRgHmO5SbPBiSwzKwVz4_ag@mail.gmail.com>
References: <bug-32832-10286@https.bugzilla.kernel.org/>
	<20110412161556.0641bdae.akpm@linux-foundation.org>
	<20110412.161744.27803776.davem@davemloft.net>
	<1302663327.2811.55.camel@edumazet-laptop>
	<1302663608.2811.62.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, kees@outflux.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:58944 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410Ab1DML5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 07:57:19 -0400
Received: by qyg14 with SMTP id 14so309536qyg.19
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2011 04:57:18 -0700 (PDT)
In-Reply-To: <1302663608.2811.62.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric, Cyril,

>> Since SO_REUSEPORT is not a 'stable fix', I suggest we revert the patch,
>> and eventually work on SO_REUSEPORT on net-next-2.6
>>
>> What do you think ?
>>
>
> Sorry, I should have mentioned commit id : c191a836a908d1dd6
> (tcp: disallow bind() to reuse addr/port)

Cyril's use case looks suspect. I don't think that this is a good
reason for reverting this commit.

I would love to help on adding SO_REUSEPORT option in kernel.

thanks,
Daniel.
