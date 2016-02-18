From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/2] ixgbe: use u32 instead of __u32 in model
 header
Date: Wed, 17 Feb 2016 21:23:19 -0500 (EST)
Message-ID: <20160217.212319.391166879950385790.davem@davemloft.net>
References: <20160217223453.9858.76096.stgit@john-Precision-Tower-5810>
	<1455748908.2958.22.camel@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: john.fastabend@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32900 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423366AbcBRCXV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 21:23:21 -0500
In-Reply-To: <1455748908.2958.22.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 17 Feb 2016 14:41:48 -0800

> On Wed, 2016-02-17 at 14:34 -0800, John Fastabend wrote:
>> I incorrectly used __u32 types where we should be using u32 types
>> when
>> I added the ixgbe_model.h file.
>>=20
>> Fixes: 9d35cf062e05 ("net: ixgbe: add minimal parser details for
>> ixgbe")
>> Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>> =A0drivers/net/ethernet/intel/ixgbe/ixgbe_model.h |=A0=A0 18 +++++++=
++-----
>> ----
>> =A01 file changed, 9 insertions(+), 9 deletions(-)
>=20
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
> Dave feel free to pull this series in from John to fix the issues wit=
h
> his previous series.

Will do.
