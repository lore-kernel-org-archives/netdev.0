From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH v2 net-next 0/2] net: print net_device name/state more often
Date: Thu, 17 Jul 2014 17:25:23 +0200
Message-ID: <CAG-2HqXVh5dM-1Fiu3H2y_3mv_cMy9+kcC=2EkwvKvL952bCjA@mail.gmail.com>
References: <1405606186-13703-1-git-send-email-vfalico@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D17276E6E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Veaceslav Falico <vfalico@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Baron <jbaron@akamai.com>,
	Eric Dumazet <edumazet@google.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	stephen hemminger <stephen@networkplumber.org>,
	Jerry Chu <hkchu@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f52.google.com ([209.85.213.52]:65212 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932865AbaGQPZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 11:25:44 -0400
Received: by mail-yh0-f52.google.com with SMTP id t59so1419438yho.11
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 08:25:43 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17276E6E@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2014 at 4:48 PM, David Laight <David.Laight@aculab.com> wrote:
> From: Veaceslav Falico
>> Currently we use net_device->name only if it's the NETREG_REGISTERED
>> reg_state, otherwise we return "(unregistered device)".
>>
>> However, we always populate net_device->name on creation, so it's always
>> available to us for use. The only caveat is that we might have a name like
>> "eth%d", in which case we cannot use it as it might change in the future.
>
> While you've got this code out on the operating table what about:
> 1) Tracing the renames into the kernel message buffer.

udev will log to dmesg what renames it does. I agree it would make
more sense to do this from the kernel though, as there are other ways
to rename interfaces than through udev.

Cheers,

Tom

> 2) Including the original name in some of the kernel traces.
>
> I've been trying to diagnose some issues on a system that renames
> its interfaces, and it can get tricky working out which interface
> messages refer to.
