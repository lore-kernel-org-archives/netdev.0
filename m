From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] netlink: downgrade warning about leftover bytes to debug
 level
Date: Wed, 28 May 2014 14:47:33 +0200
Message-ID: <5385DAE5.2020009@6wind.com>
References: <1401196563-6999-1-git-send-email-mschmidt@redhat.com> <53859359.70304@6wind.com> <5385A9D1.4000102@redhat.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Michal Schmidt <mschmidt@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:61146 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753325AbaE1Mrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 08:47:36 -0400
Received: by mail-wi0-f171.google.com with SMTP id cc10so3541848wib.16
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 05:47:35 -0700 (PDT)
In-Reply-To: <5385A9D1.4000102@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 28/05/2014 11:18, Michal Schmidt a =C3=A9crit :
> On 05/28/2014 09:42 AM, Nicolas Dichtel wrote:
>> Le 27/05/2014 15:16, Michal Schmidt a =C3=A9crit :
>>> Any process is able to send netlink messages with leftover bytes, s=
o
>>> downgrade the warning message to pr_debug in order to avoid possibl=
e
>>> kernel log spam.
>> Yes, but that's not a normal case. I think that the level warning is=
 good,
>> there is something wrong with this kind of messages.
>
> As an alternative we could at least guard it with net_ratelimit().
I would prefer this solution.

>
> But still, the message indicates a userspace bug. It can be useful
> for a developer of a netlink library, but not for many more.
Or to let you know why a userspace tool does not work ;-)

> I think it's odd to let unprivileged userspace spam the dmesg,
> even if rate-limited. The kernel does not emit warning messages when
> userspace is buggy in other ways, like calling syscalls with invalid
> arguments.
If it's really a problem (this message is here since 2.6.15 and nobody
complains), maybe a level between warning and debug may be acceptable.


Regards,
Nicolas
