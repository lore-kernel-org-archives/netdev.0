From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [RFC PATCH 0/2] Faster/parallel SYN handling to mitigate SYN
 floods
Date: Wed, 30 May 2012 10:53:08 +0200
Message-ID: <4FC5DFF4.1020604@uclouvain.be>
References: <20120528115102.12068.79994.stgit@localhost.localdomain> <4FC3A465.4030203@uclouvain.be> <1338322661.7747.17.camel@localhost> <4FC53353.2050801@uclouvain.be> <1338367497.7747.72.camel@localhost>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, Florian Westphal <fw@strlen.de>,
	opurdila@ixiacom.com,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Andi Kleen <andi@firstfloor.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:48596 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932368Ab2E3IxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 04:53:14 -0400
In-Reply-To: <1338367497.7747.72.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/2012 10:44 AM, Jesper Dangaard Brouer wrote:
>> >=20
>> > Then the receiver will receive two SYN/ACK's for the same SYN with
>> > different sequence-numbers. As the "SYN cookie SYN-ACK" will arriv=
e
>> > second, it will be discarded and seq-numbers from the first one wi=
ll be
>> > taken on the client-side.
> I thought that the retransmitted SYN packet, were caused by the SYN-A=
CK
> didn't reach the client?

Or, if the SYN/ACK got somehow delayed in the network and the
SYN-retransmission timer on the client-side fires before the SYN/ACK
reaches the client.


Christoph


--=20
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://mptcp.info.ucl.ac.be
Universit=C3=A9 Catholique de Louvain
--=20
