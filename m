From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: 3.10-stable commits missing in 3.12-stable
Date: Tue, 07 Apr 2015 14:41:14 +0200
Message-ID: <5523D06A.5080405@suse.cz>
References: <551E69CA.4040603@suse.cz> <20150403.122221.1151334897354117399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20150403.122221.1151334897354117399.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/03/2015, 06:22 PM, David Miller wrote:
> From: Jiri Slaby <jslaby@suse.cz>
> Date: Fri, 03 Apr 2015 12:22:02 +0200
> 
>> I am crawling through commits which are in 3.10-stable but are not in
>> 3.12-stable. Could you either ACK them so that I can pick them or
>> include them in the next stable NETWORKING patches, please?
> 
> Sorry, I am not going through arbitrary non-trivial sets of commits.
> 
> I'm willing to look at individual -stable backport candidates
> on a case by case basis with a well worded and well thought
> out justification for each candidate from the person interested
> in seeing the -stable submission because it effects something
> they care about.
> 
> But wholesale collections like this, I'm not going to invest the time
> into.  It's not reasonable at all.

Ok, while I understand the point, all the patches are in all 3.2, 3.4,
3.10, 3.13, or 3.14 if applicable. Hence, if somebody decides to update
to 3.12, they might hit an already fixed regression.

They haven't got into 3.12 because 3.12 was missed by some of your
backport batches. Details are below per each patch.

So I applied them all. I.e. I did what Greg and others do when you
provide us with backports for some stable trees, but the ones which are
still maintained, are missing the backport batch.

Thanks.

> =========================
>
> Subject: net/mlx4_core: Preserve pci_dev_data after __mlx4_remove_one()
>
> From: Wei Yang <weiyang@linux.vnet.ibm.com>
>
> [ Upstream commit befdf8978accecac2e0739e6b5075afc62db37fe ]

Source: [PATCHES] Networking (Tue, 17 Jun 2014)
URL: http://www.spinics.net/lists/stable/msg50352.html
Patches for: 3.2, 3.4, 3.10, 3.14, 3.15
CommitDate: Thu Jun 26
In stable: 3.4, 3.10, 3.14

PUSHED to 3.12

> =========================
>
> Subject: net: fix sparse warning in sk_dst_set()
>
> From: Eric Dumazet <edumazet@google.com>
>
> [ Upstream commit 5925a0555bdaf0b396a84318cbc21ba085f6c0d3 ]

Source: [PATCHES] Networking (Thu, 24 Jul 2014)
URL: http://www.spinics.net/lists/stable/msg56176.html
Patches for: 3.2, 3.4, 3.10, 3.14, 3.15
CommitDate: Mon Jul 28
In stable: 3.10, 3.14, 3.15

PUSHED to 3.12

> =========================
>
> Subject: net: mvneta: Fix big endian issue in mvneta_txq_desc_csum()
>
> From: Thomas Fitzsimmons <fitzsim@fitzsim.org>
>
> [ Upstream commit 0a1985879437d14bda8c90d0dae3455c467d7642 ]

Source: [PATCHES] Networking (Thu, 24 Jul 2014)
URL: http://www.spinics.net/lists/stable/msg56176.html
Patches for: 3.2, 3.4, 3.10, 3.14, 3.15
CommitDate: Mon Jul 28
In stable: 3.10, 3.14, 3.15

PUSHED to 3.12

> =========================
>
> Subject: dns_resolver: Null-terminate the right string
>
> From: Ben Hutchings <ben@decadent.org.uk>
>
> [ Upstream commit 640d7efe4c08f06c4ae5d31b79bd8740e7f6790a ]

Source: [PATCHES] Networking (Thu, 24 Jul 2014)
URL: http://www.spinics.net/lists/stable/msg56176.html
Patches for: 3.2, 3.4, 3.10, 3.14, 3.15
CommitDate: Mon Jul 28
In stable: 3.4, 3.10, 3.14, 3.15

PUSHED to 3.12

> =========================
>
> Subject: core, nfqueue, openvswitch: Orphan frags in skb_zerocopy and
> handle errors
>
> From: Zoltan Kiss <zoltan.kiss@citrix.com>
>
> commit 36d5fe6a000790f56039afe26834265db0a3ad4c upstream.

Source: provided backport
URL: http://openvswitch.org/pipermail/dev/2014-April/039233.html
CommitDate: Thu Jul 31
In stable: 3.10, 3.13
In upstream: 3.14

PUSHED to 3.12

> =========================


The following five:
CommitDate: Thu Aug 7
In stable: 3.10, 3.11, 3.13

> Subject: net: mvneta: increase the 64-bit rx/tx stats out of the hot path
>
> From: willy tarreau <w@1wt.eu>
>
> commit dc4277dd41a80fd5f29a90412ea04bc3ba54fbf1 upstream.
>
> =========================
>
> Subject: net: mvneta: use per_cpu stats to fix an SMP lock up
>
> From: willy tarreau <w@1wt.eu>
>
> commit 74c41b048db1073a04827d7f39e95ac1935524cc upstream.
>
> =========================
>
> Subject: net: mvneta: do not schedule in mvneta_tx_timeout
>
> From: willy tarreau <w@1wt.eu>
>
> commit 290213667ab53a95456397763205e4b1e30f46b5 upstream.
>
> =========================
>
> Subject: net: mvneta: add missing bit descriptions for interrupt masks
> and causes
>
> From: willy tarreau <w@1wt.eu>
>
> commit 40ba35e74fa56866918d2f3bc0528b5b92725d5e upstream.
>
> =========================
>
> Subject: net: mvneta: replace Tx timer with a real interrupt
>
> From: willy tarreau <w@1wt.eu>
>
> commit 71f6d1b31fb1f278a345a30a2180515adc7d80ae upstream.


PUSHED to 3.12


> =========================
>
> Subject: ipv6: reallocate addrconf router for ipv6 address when lo
> device up
>
> From: Gao feng <gaofeng@cn.fujitsu.com>
>
> [ Upstream commit 33d99113b1102c2d2f8603b9ba72d89d915c13f5 ]

Source: [PATCHES] Networking (Sat, 11 Oct 2014)
URL: http://www.spinics.net/lists/stable/msg64708.html
Patches for: 3.10, 3.14, 3.16, 3.17
CommitDate: Wed Oct 15
In stable: 3.4, 3.10
In upstream: 3.14

PUSHED to 3.12



-- 
js
suse labs
