From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 0/3] netfilter : 3 patches to boost ip_tables performance
Date: Thu, 22 Sep 2005 15:30:39 +0200
Message-ID: <4332B1FF.8040202@cosmosbay.com>
References: <432EF0C5.5090908@cosmosbay.com> <43308324.70403@cosmosbay.com> <4331CFA7.50104@cosmosbay.com> <200509221503.21650.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030313AbVIVNan@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200509221503.21650.ak@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen a =C3=A9crit :
>>1) No more central rwlock protecting each table (filter, nat, mangle,=
 raw),
>>    but one lock per CPU. It avoids cache line ping pongs for each pa=
cket.
>=20
>=20
> Another useful change would be to not take the lock when there are no
> rules. Currently just loading iptables has a large overhead.
>=20

Unfortunatly there are allways rules, after the loading of iptables, at=
 least=20
for the "packet_filter" table.

Eric
