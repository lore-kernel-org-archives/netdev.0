From: Chase Douglas <chase.douglas@canonical.com>
Subject: Re: [PATCH 1/1] 3c59x: Acquire vortex lock instead of disabling irq
Date: Wed, 17 Mar 2010 14:44:30 -0400
Message-ID: <40ec3ea41003171144s6acbf2fdl4434f2147b8244a0@mail.gmail.com>
References: <1268836396-23943-2-git-send-email-chase.douglas@canonical.com>
	 <20100317.110320.15445884.davem@davemloft.net>
	 <40ec3ea41003171120x26d2e8b4q6b59c992ab28e454@mail.gmail.com>
	 <20100317.112706.143765408.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f200.google.com ([209.85.222.200]:60884 "EHLO
	mail-pz0-f200.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162Ab0CQSob convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 14:44:31 -0400
Received: by pzk38 with SMTP id 38so1107774pzk.33
        for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 11:44:31 -0700 (PDT)
In-Reply-To: <20100317.112706.143765408.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 17, 2010 at 2:27 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Chase Douglas <chase.douglas@canonical.com>
> Date: Wed, 17 Mar 2010 14:20:45 -0400
>
>> If that's the case, what's the solution? It's not safe to call
>> disable_irq* in softirq context anymore.
>
> That's a huge problem, because such a restriction has broken
> several drivers. =A03c59x is not the only one which uses this
> technique for this reason. =A0The 8390 one does too.

So basically the answer right now is: it's broken and needs to be
reworked, and a switch to disabling irqs is deemed inadequate. Is that
accurate?

If that's a fair statement of the current drivers, then I can go back
and inform end users of this when they hit the bug.

-- Chase
