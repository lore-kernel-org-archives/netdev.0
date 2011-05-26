From: Laurent Riffard <laurent.riffard@free.fr>
Subject: Re: [BUG] netconsole broken by scheduler updates
Date: Thu, 26 May 2011 18:12:27 +0200
Message-ID: <4DDE7BEB.1050507@free.fr>
References: <4DDE1B7D.7080707@free.fr> <1306403308.1200.44.camel@twins> <alpine.DEB.2.02.1105261217240.5114@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:40354 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751928Ab1EZQMg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 May 2011 12:12:36 -0400
In-Reply-To: <alpine.DEB.2.02.1105261217240.5114@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/05/2011 12:35, Laurent Riffard a =E9crit :
> On Thu, 26 May 2011, Peter Zijlstra wrote:
>> On Thu, 2011-05-26 at 11:21 +0200, Laurent Riffard wrote:
>>> Hi,
>>>
>>> Recently, netconsole was broken by some scheduler updates. Kernel h=
angs
>>> on boot near the network card initialization. I noticed that it doe=
s
>>> hang just where a "inconsistent lock state" message normally appear=
s.
>>>
>>> I did a bisection : e4a52bcb9a18142d79e231b6733cabdbf2e67c1f is the
>>> first bad commit.
>>> commit e4a52bcb9a18142d79e231b6733cabdbf2e67c1f
>>> Author: Peter Zijlstra <a.p.zijlstra@chello.nl>
>>> Date:   Tue Apr 5 17:23:54 2011 +0200
>>>
>>>     sched: Remove rq->lock from the first half of ttwu()
>>>
>>>
>>> Before this commit, kernel was booting succesfully despite the
>>> "inconsistent lock state" message. After this commit, the kernel do=
es
>>> hang on boot, I have to push the reset button.
>>
>> Do you have CONFIG_HARDLOCKUP_DETECTOR=3Dy, and do you get an NMI sp=
lat
>> after some 10 seconds? It would be interesting to see where its stuc=
k.
>=20
> CONFIG_HARDLOCKUP_DETECTOR is not set for now. I'll give it a try.

I activated CONFIG_HARDLOCKUP_DETECTOR, but failed to obtain more=20
information. During the boot, the kernel hangs just after bringing up=20
the NIC. I waited 2 minutes, without getting any more messages.

~~
laurent

