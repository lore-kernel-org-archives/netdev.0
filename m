From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH 19/25] mlx4: Randomizing mac addresses for slaves
Date: Wed, 4 Nov 2009 23:33:28 +0200
Message-ID: <15ddcffd0911041333l165ee274mfae3508a3db755e7@mail.gmail.com>
References: <4AF19E69.8070605@mellanox.co.il> <adar5seys3e.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:53635 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758183AbZKDVdY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:33:24 -0500
In-Reply-To: <adar5seys3e.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 4, 2009 at 10:04 PM, Roland Dreier <rdreier@cisco.com> wrot=
e:
>> +#define MLX4_MAC_HEAD =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x2c9000000ULL

> Is this a good idea? =A0You're basically choosing 24 random bits with=
in your OUI...
> seems the chance of collision with another MAC used on the same netwo=
rk is
> high enough that it could easily happen in practice on a moderately b=
ig network.

yes, this has been brought by Stephen and others on this last back on
September 11th, this year @
http://marc.info/?l=3Dlinux-netdev&m=3D125263488409128

> Can you pick a reserved range or something?

Using different OUI for the VF device wouldn't help either I think,
since the #VF becomes fairly big even on a modest side cluster with
(say) a VM consuming VF per 1-2 cores.

Or.
