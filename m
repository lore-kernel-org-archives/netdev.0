From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Badness at net/ipv4/inet_connection_sock.c:293
Date: Mon, 14 Dec 2009 20:23:32 +0100
Message-ID: <4B2690B4.3030604@gmail.com>
References: <4B267708.3010202@gmail.com>	<1260817033.9141.8.camel@merlyn>	<20091214.111105.224947761.davem@davemloft.net> <20091214.111638.165984790.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: john.dykstra1@gmail.com, lists@nerdbynature.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932537AbZLNTXk@vger.kernel.org>
In-Reply-To: <20091214.111638.165984790.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 14/12/2009 20:16, David Miller a =E9crit :
> From: David Miller <davem@davemloft.net>
> Date: Mon, 14 Dec 2009 11:11:05 -0800 (PST)
>=20
>> I usually see 2 or 3 three of these bug triggers in the first ten
>> minutes after bootup and I haven't seen one yet in 20 minutes
>> with the commit reverted.
>=20
> Nevermind, I take that back, I just got two triggers :-/

ok :)

More investigation needed :)

I wonder which workload triggers this...

If you disable syncookies, I presume you dont have warnings ?
