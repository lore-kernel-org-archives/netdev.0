From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Badness at net/ipv4/inet_connection_sock.c:293
Date: Mon, 14 Dec 2009 20:22:13 +0100
Message-ID: <4B269065.5000601@gmail.com>
References: <20091213.234530.82029083.davem@davemloft.net>	<4B267708.3010202@gmail.com>	<1260817033.9141.8.camel@merlyn> <20091214.111105.224947761.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: john.dykstra1@gmail.com, lists@nerdbynature.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932512AbZLNTWT@vger.kernel.org>
In-Reply-To: <20091214.111105.224947761.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 14/12/2009 20:11, David Miller a =E9crit :
> From: John Dykstra <john.dykstra1@gmail.com>
> Date: Mon, 14 Dec 2009 18:57:13 +0000
>=20
>> That test was changed to match a change in the return values of
>> tcp_ack().  No logic change was intended.
>=20
> As Eric pointed out, changing tcp_ack()'s behavior effects state
> transitions out of SYN_ACK, so this commit is very likely the culprit=
=2E
>=20
> I usually see 2 or 3 three of these bug triggers in the first ten
> minutes after bootup and I haven't seen one yet in 20 minutes
> with the commit reverted.
>=20
> This change is definitely wrong.

Hmm, I didnt yet spotted the problem, just gave some hints ...
