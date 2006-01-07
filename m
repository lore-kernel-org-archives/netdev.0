From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH, RFC] RCU : OOM avoidance and lower latency
Date: Sat, 07 Jan 2006 08:34:35 +0100
Message-ID: <43BF6F0B.4060108@cosmosbay.com>
References: <43BEA693.5010509@cosmosbay.com> <200601062157.42470.ak@suse.de> <20060106.161721.124249301.davem@davemloft.net> <200601070209.02157.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, paulmck@us.ibm.com,
	alan@lxorguk.ukuu.org.uk, torvalds@osdl.org,
	linux-kernel@vger.kernel.org, dipankar@in.ibm.com,
	manfred@colorfullife.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932240AbWAGHez@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200601070209.02157.ak@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen a =E9crit :
>=20
> I always disliked the per chain spinlocks even for other hash tables =
like
> TCP/UDP multiplex - it would be much nicer to use a much smaller sepa=
rately=20
> hashed lock table and save cache. In this case the special case of us=
ing
> a one entry only lock hash table makes sense.
>=20

I agree, I do use a hashed spinlock array on my local tree for TCP, mai=
nly to=20
reduce the hash table size by a 2 factor.

Eric
