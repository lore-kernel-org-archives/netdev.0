From: Kirill Smelkov <kirr@mns.spb.ru>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for
	single TCP session balancing
Date: Tue, 18 Jan 2011 20:56:15 +0300
Message-ID: <20110118175615.GA6486@tugrik.mns.mnsspb.ru>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru> <26330.1295049912@death> <4D35060D.5080004@intel.com> <4D358A47.4020009@yandex-team.ru> <4D35A9B4.7030701@gmail.com> <4D35B1B0.2090905@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?iso-8859-1?Q?S=E9bastien_Barr=E9?= <sebastien.barre@uclouvain.be>,
	Christophe Paasch <christoph.paasch@uclouvain.be>
To: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mnsspb.ru ([84.204.75.2]:45030 "EHLO mail.mnsspb.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750867Ab1ARRzO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jan 2011 12:55:14 -0500
Content-Disposition: inline
In-Reply-To: <4D35B1B0.2090905@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 18, 2011 at 06:28:48PM +0300, Oleg V. Ukhno wrote:
> On 01/18/2011 05:54 PM, Nicolas de Peslo=FCan wrote:
>> Le 18/01/2011 13:40, Oleg V. Ukhno a =E9crit :
[...]

>> Oleg, would you mind trying the above "two VLAN" topology" with
>> mode=3Dbalance-rr and report any results ? For high-availability pur=
pose,
>> it's obviously necessary to setup those VLAN on distinct switches.
> I'll do it, but it will take some time to setup test environment, =20
> several days may be.
> You mean following topology:
>           switch 1
>        /           \
> host A                host B
>        \  switch 2 /
>

=46YI: I'm in the process of developing new redundancy mode for bonding=
,
and while at it, the following script is maybe useful for you too, so
that bonding testing can be done entirely on one host:

http://repo.or.cz/w/linux-2.6/kirr.git/blob/refs/heads/x/etherdup:/tool=
s/bonding/mk-tap-loops.sh


Sorry for maybe being offtopic,
Kirill
