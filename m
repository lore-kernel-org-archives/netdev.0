From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [2.6.33-rc5] kernel BUG at include/net/netns/generic.h:41!
Date: Fri, 29 Jan 2010 12:17:26 +0200
Message-ID: <b6fcc0a1001290217l4edb0a0btbafa0c26b6f14ad5@mail.gmail.com>
References: <20100129094822.GA8294@nb-core2.darkstar.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Luca Tettamanti <kronos.it@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f186.google.com ([209.85.223.186]:49201 "EHLO
	mail-iw0-f186.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756893Ab0A2KR1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 05:17:27 -0500
In-Reply-To: <20100129094822.GA8294@nb-core2.darkstar.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 29, 2010 at 11:48 AM, Luca Tettamanti <kronos.it@gmail.com>=
 wrote:
> with recent kernels I'm seeing this BUG - triggered by racoon - at bo=
ot:
>
> NET: Registered protocol family 15
> ------------[ cut here ]------------
> kernel BUG at /home/kronos/src/linux-2.6.git/include/net/netns/generi=
c.h:43!
> invalid opcode: 0000 [#1] PREEMPT SMP
> last sysfs file: /sys/kernel/uevent_seqnum
> CPU 1
> Pid: 1941, comm: racoon Not tainted 2.6.33-rc5-00271-gbe8cde8-dirty #=
238 F3Sa =A0 =A0 =A0/F3Sa
> RIP: 0010:[<ffffffffa03035be>] =A0[<ffffffffa03035be>] pfkey_create+0=
x36/0x18b [af_key]

Does it triggers after succesfull boot if you do

    rmmod af_key; modprobe af_key

a couple of times?

Post .config, just in case.
