From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] af_key: locking change
Date: Sat, 20 Feb 2010 12:51:45 -0800 (PST)
Message-ID: <20100220.125145.173499637.davem@davemloft.net>
References: <20100219220111.868268353@vyatta.com>
	<1266638850.2839.6.camel@edumazet-laptop>
	<20100219215314.66d6f857@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, viro@zeniv.linux.org.uk,
	akpm@linux-foundation.org, rusty@rustcorp.com.au,
	oberpar@linux.vnet.ibm.com, mszeredi@suse.cz,
	paulmck@linux.vnet.ibm.com, jpirko@redhat.com, jolsa@redhat.com,
	mingo@elte.hu, adobriyan@gmail.com, hadi@cyberus.ca,
	nhorman@tuxdriver.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42045
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756078Ab0BTUv3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Feb 2010 15:51:29 -0500
In-Reply-To: <20100219215314.66d6f857@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 19 Feb 2010 21:53:14 -0800

> On Sat, 20 Feb 2010 05:07:30 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
>> Le vendredi 19 f=E9vrier 2010 =E0 13:59 -0800, Stephen Hemminger a =E9=
crit :
>> > pi=E8ce jointe document texte brut (pfkey-rcu.patch)
>> > Get rid of custom locking that was using wait queue, lock, and ato=
mic
>> > to basically build a queued mutex.  Use RCU for read side.
>> >=20
>> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>=20
>> Excellent
>>=20
>> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>>=20
>> I dont know why you used synchronize_sched() instead of
>> synchronize_rcu().
>=20
> I'll go back to synchronize_rcu.

Please also add some comments for patch #1 as requested by
Al Viro.

When you post the new series with these changes I'll apply
it to net-next-2.6, thanks!
