From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 0/2] udp: Convert the UDP hash lock to RCU
Date: Tue, 28 Oct 2008 22:50:49 +0100
Message-ID: <49078939.6090709@cosmosbay.com>
References: <m37i8k3hv1.fsf@ursa.amorsen.dk>	<48EB5D28.7000503@cosmosbay.com>	<20081007160729.60c076c4@speedy>	<20081007.135548.56141000.davem@davemloft.net>	<48ECBBD8.9060602@cosmosbay.com>	<490777FB.2070506@cosmosbay.com> <20081028142821.5f4718e8@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, benny+usenet@amorsen.dk,
	minyard@acm.org, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com, Christoph Lameter <clameter@sgi.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:34836 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752793AbYJ1WHJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 18:07:09 -0400
In-Reply-To: <20081028142821.5f4718e8@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> On Tue, 28 Oct 2008 21:37:15 +0100
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>> We use RCU only for fast path. Thus, /proc/net/udp still take rdlock=
s.
>=20
> We should just make it a spin_lock later and speed up udp socket crea=
tion.

Indeed

