From: Joao Correia <joaomiguelcorreia@gmail.com>
Subject: Fwd: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (
	possibly?caused by netem)
Date: Tue, 7 Jul 2009 12:05:55 +0100
Message-ID: <a5d9929e0907070405p63698ec7t5b5fad394533e4a7@mail.gmail.com>
References: <200907031326.21822.andres@anarazel.de> <20090707065014.GA3296@ami.dom.local>
	<a5d9929e0907070340y63280508t92e6c7e4ce464994@mail.gmail.com>
	<200907071247.16977.andres@anarazel.de> <a5d9929e0907070403n698c9eb9p53a5bb07bafcc169@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:63055 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754194AbZGGLGN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 07:06:13 -0400
In-Reply-To: <a5d9929e0907070403n698c9eb9p53a5bb07bafcc169@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC'ing the list and other listeners, that were left out in the previous=
 email.

Joao Correia


---------- Forwarded message ----------
=46rom: Joao Correia <joaomiguelcorreia@gmail.com>
Date: Tue, Jul 7, 2009 at 12:03 PM
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (
possibly?caused by netem)
To: Andres Freund <andres@anarazel.de>


I dont see the problem with the patch from Jarek. (sorry for not being
clear about this).

With vanilla 31-rc2 it is still there.

Joao Correia

On Tue, Jul 7, 2009 at 11:47 AM, Andres Freund<andres@anarazel.de> wrot=
e:
> On Tuesday 07 July 2009 12:40:16 Joao Correia wrote:
>> I am now running 2.6.31-rc2 for a couple of hours, no freeze.
>>
>> Let me know what/if i can help with tracking down the original sourc=
e
>> of the problem.
> You dont see the problem anymore with the `echo 0 >
> /proc/sys/kernel/timer_migration` =A0change (or equivalently with the=
 patch from
> Jarek) or has the problem vanished completely?
>
> Andres
>
