From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ixgbe: fix error handling in tc cls_u32
 offload routines.
Date: Fri, 04 Mar 2016 14:15:43 -0500 (EST)
Message-ID: <20160304.141543.274795518608904439.davem@davemloft.net>
References: <1457047192-17092-1-git-send-email-sridhar.samudrala@intel.com>
	<1457048272.2936.12.camel@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sridhar.samudrala@intel.com, john.r.fastabend@intel.com,
	netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34950 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758765AbcCDTPp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 14:15:45 -0500
In-Reply-To: <1457048272.2936.12.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 03 Mar 2016 15:37:52 -0800

> On Thu, 2016-03-03 at 15:19 -0800, Sridhar Samudrala wrote:
>> Check for handle ids when adding/deleting hash nodes OR
>> adding/deleting
>> filter entries and limit them to max number of links or header nodes
>> supported(IXGBE_MAX_LINK_HANDLE).
>>=20
>> Start from bit 0 when setting hash table bit-map.(adapter->tables)
>>=20
>> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
>> ---
>> =A0drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 52
>> +++++++++++++++++----------
>> =A01 file changed, 34 insertions(+), 18 deletions(-)
>=20
> Dave I will add this to my queue

Ok.
