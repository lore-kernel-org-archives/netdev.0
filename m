From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2 00/14] Move vlan acceleration into networking core.
Date: Thu, 21 Oct 2010 12:32:33 -0700
Message-ID: <AANLkTikiv53_r3vAWa+ejRfBAHmeiUXnWuBR=_1vOR3_@mail.gmail.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
	<1287626579.11431.9.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37024 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774Ab0JUTcf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 15:32:35 -0400
Received: by fxm16 with SMTP id 16so470810fxm.19
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 12:32:34 -0700 (PDT)
In-Reply-To: <1287626579.11431.9.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 20, 2010 at 7:02 PM, David Dillow <dave@thedillows.org> wro=
te:
> On Wed, 2010-10-20 at 16:56 -0700, Jesse Gross wrote:
>> The first eleven patches can be applied immediately, while the last =
three need
>> to wait until all drivers that support vlan acceleration are updated=
=2E =A0If
>> people agree that this patch set makes sense I will go ahead and swi=
tch over
>> the dozen or so drivers that would need to change.
>
> Here's a first pass at converting typhoon to the new methods. It is
> compile tested, but I have to put the hardware back in a machine to d=
o
> some testing, which I may not be able to do before the weekend.
>
> Of course, we could just change it to not offload by default if we ne=
ed
> to push this sooner.
>
> Applies to net-next-2.6 with the vlan changes.

This is great, thanks.  Much better to have someone who actually knows
what's going on, rather than me trying to randomly guess...
