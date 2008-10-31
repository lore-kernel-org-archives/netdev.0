From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Fri, 31 Oct 2008 22:03:00 +0100
Message-ID: <490B7284.2010003@cosmosbay.com>
References: <Pine.LNX.4.64.0810302047030.22084@wrl-59.cs.helsinki.fi> <20081031.005219.141937694.davem@davemloft.net> <Pine.LNX.4.64.0810311119510.7072@wrl-59.cs.helsinki.fi> <20081031.025159.51432990.davem@davemloft.net> <490AE1CD.9040207@cosmosbay.com> <20081031125713.6c6923de@extreme> <20081031201016.GA4748@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, ilpo.jarvinen@helsinki.fi,
	rjw@sisk.pl, mingo@elte.hu, s0mbre@tservice.net.ru,
	a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, efault@gmx.de, akpm@linux-foundation.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753424AbYJaVEZ@vger.kernel.org>
In-Reply-To: <20081031201016.GA4748@ioremap.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov a =E9crit :
> On Fri, Oct 31, 2008 at 12:57:13PM -0700, Stephen Hemminger (shemming=
er@vyatta.com) wrote:
>> Why bother with last_rx at all on loopback.  I have been thinking
>> we should figure out a way to get rid of last_rx all together. It on=
ly
>> seems to be used by bonding, and the bonding driver could do the cal=
culation
>> in its receive handling.
>=20
> Not related to the regression: bug will be just papered out by this
> changes. Having bonding on loopback is somewhat strange idea, but sti=
ll
> this kind of changes is an attempt to make a good play in the bad gam=
e:
> this loopback-only optimization does not fix the problem.
>=20

Just to be clear, this change was not meant to be committed.
It already was rejected by David some years ago (2005, and 2006)

http://www.mail-archive.com/netdev@vger.kernel.org/msg07382.html

If you read my mail, I was *only* saying that tbench results can be sen=
sible to
cache line ping pongs. tbench is a crazy benchmark, and only is a crazy=
 benchmark.

Optimizing linux for tbench sake would be .... crazy ?
