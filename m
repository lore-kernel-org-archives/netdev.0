From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 PATCH 1/8] e1000e: cleanup ethtool loopback setup
	code
Date: Sun, 20 Jun 2010 00:32:20 -0700
Message-ID: <AANLkTik2Rait7ugcDt36ncwqdO-fZrr9iM8usecAyBAC@mail.gmail.com>
References: <20100616232523.4834.84849.stgit@localhost.localdomain>
	<20100618.221512.102550313.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	bruce.w.allan@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:48264 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109Ab0FTHcV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jun 2010 03:32:21 -0400
Received: by iwn9 with SMTP id 9so2416598iwn.19
        for <netdev@vger.kernel.org>; Sun, 20 Jun 2010 00:32:20 -0700 (PDT)
In-Reply-To: <20100618.221512.102550313.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 18, 2010 at 22:15, David Miller <davem@davemloft.net> wrote=
:
>
> I've applied this series however:
>
> 1) Please address Ben's concerns about turning EEE on by default
> =C2=A0 given that standardization is not complete yet.
>
> 2) I hate module parameters, I'd rather you create a new ethtool
> =C2=A0 feature bit and thus allow the setting to be modified at run
> =C2=A0 time. =C2=A0Please create a new ethtool control flag, and remo=
ve
> =C2=A0 this module option.
>
> Thanks.
> --

Thank you Dave.  I know that Bruce (and company) are actively looking
into your first point.  I would think that he would have either a
response or update on the status come Monday/Tuesday.

Regarding option 2, understood and I will work out with Bruce on when
and who will do the work.  I will be taking a look at it tomorrow
(later today), if I am not able to come up with a patch in the near
future.  I will return to working on it by Wednesday.

--=20
Cheers,
Jeff
