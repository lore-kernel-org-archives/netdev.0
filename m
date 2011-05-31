From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: netxen_nic: unregister_netdevice error
Date: Tue, 31 May 2011 12:12:15 +0200
Message-ID: <20110531101214.GB2763@psychotron.brq.redhat.com>
References: <4DE4877C.1070704@gmail.com>
 <4DE4B31A.3090201@gmail.com>
 <1306835326.2809.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: WeipingPan <panweiping3@gmail.com>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39550 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750762Ab1EaKMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 May 2011 06:12:18 -0400
Content-Disposition: inline
In-Reply-To: <1306835326.2809.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 31, 2011 at 11:48:46AM CEST, eric.dumazet@gmail.com wrote:
>Le mardi 31 mai 2011 =E0 17:21 +0800, WeipingPan a =E9crit :
>> On 05/31/2011 02:15 PM, WeipingPan wrote:
>> > hi,
>> >
>> > When test bonding broadcast mode I met a problem.
>> > modprobe -r bonding will fail after I ping broadcast address.
>> >
>> > I find that the problem only shows up when I use netxen_nic driver=
=2E
>> > When use ixgbe and bn2x2 driver, no problem occurs.
>> >
>> > I use RHEL 6.2, kernel 2.6.32-131.0.15.el6.i686,
>> > Can anybody confirm this bug using 2.6.39 or upstream ?
>> >
>> > many thanks
>> > Weiping Pan
>> >
>> I got a machine to test the=20
>> upstream,55922c9d1b84b89cb946c777fddccb3247e7df2c
>> the problem disappears.
>>=20
>> many thanks
>> Weiping Pan
>
>Might be solved by commit fc75fc8339e772716744 or=20
>
>commit 332dd96f7ac15e937088fe11f15c (net/dst: dst_dev_event() called
>after other notifiers) and commit ef885afbf8a37689 ((net: use
>rcu_barrier() inrollback_registered_many)

Thanks, for suggestions Eric. We'll try those.

>
>
>
>
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
