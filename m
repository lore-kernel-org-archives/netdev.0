From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: BUG ? ipip unregister_netdevice_many()
Date: Fri, 08 Oct 2010 09:51:14 -0700
Message-ID: <m1ocb41vct.fsf@fess.ebiederm.org>
References: <201010071048.12817.hans.schillstrom@ericsson.com>
	<4CAEFE2C.3010007@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:51560 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757940Ab0JHQvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 12:51:19 -0400
In-Reply-To: <4CAEFE2C.3010007@free.fr> (Daniel Lezcano's message of "Fri, 08
	Oct 2010 13:19:08 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano <daniel.lezcano@free.fr> writes:

> On 10/07/2010 10:48 AM, Hans Schillstrom wrote:
>> Hello
>> I'm trying to exit a network name space and it doesn't work (or am I doing something wrong?)
>> The only netdevices left are lo and the tunnels ip6tnl0, sit0 and tunl0 when exiting netns.
>>
>> A netns is created by lxc-execute with two interfaces eth0 eth1 (macvlan)
>> (see conf file at the end)
>>
>> Kernel: net-next-2.6 top from 4 october 2010
>>    
>
> Hi Hans,
>
> I tried to reproduce your problem but I just get a big kernel crash when exiting
> the container :/
>
> The stack is different but it may be related to the same problem.

Double ouch.  My guess that this is more related to the recent macvlan
changes.

It looks like there is plenty of debugging work to do :(

Ouch Ouch Ouch!

Eric
