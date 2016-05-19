From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/2] Follow-ups for GUEoIPv6 patches
Date: Wed, 18 May 2016 21:10:43 -0700 (PDT)
Message-ID: <20160518.211043.773402183440053556.davem@davemloft.net>
References: <20160518173605.2608.42484.stgit@localhost.localdomain>
	<1463606878.2713.68.camel@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: aduyck@mirantis.com, tom@herbertland.com,
	alexander.duyck@gmail.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, kernel-team@fb.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739AbcESEKp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 00:10:45 -0400
In-Reply-To: <1463606878.2713.68.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 18 May 2016 14:27:58 -0700

> On Wed, 2016-05-18 at 10:44 -0700, Alexander Duyck wrote:
>> This patch series is meant to be applied after:
>> [PATCH v7 net-next 00/16] ipv6: Enable GUEoIPv6 and more fixes for v=
6
>> tunneling
>>=20
>> The first patch addresses an issue we already resolved in the GREv4 =
and
>> is
>> now present in GREv6 with the introduction of FOU/GUE for IPv6 based=
 GRE
>> tunnels.
>>=20
>> The second patch goes through and enables IPv6 tunnel offloads for t=
he
>> Intel
>> NICs that already support the IPv4 based IP-in-IP tunnel offloads.=A0=
 I
>> have
>> only done a bit of touch testing but have seen ~20 Gb/s over an i40e
>> interface using a v4-in-v6 tunnel, and I have verified IPv6 GRE is s=
till
>> passing traffic at around the same rate.=A0 I plan to do further tes=
ting
>> but
>> with these patches present it should enable a wider audience to be a=
ble
>> to
>> test the new features introduced in Tom's patchset with hardware
>> offloads.
>>=20
>> ---
>>=20
>> Alexander Duyck (2):
>> =A0=A0=A0=A0=A0 ip6_gre: Do not allow segmentation offloads GRE_CSUM=
 is enabled
>> with FOU/GUE
>> =A0=A0=A0=A0=A0 intel: Add support for IPv6 IP-in-IP offload
>=20
> Dave, I have this series added to my queue.

Why would you if it depends upon Tom's series, as mentioned above, whic=
h
isn't even in my tree yet?
