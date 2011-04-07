From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix skb_add_data_nocache() to calc csum
 correctly
Date: Wed, 06 Apr 2011 23:05:12 -0700 (PDT)
Message-ID: <20110406.230512.189691681.davem@davemloft.net>
References: <4D9D402C.60107@cn.fujitsu.com>
	<BANLkTikspQHnjagFme0S3GdPUo-zw48zBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37813
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751674Ab1DGGFt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 02:05:49 -0400
In-Reply-To: <BANLkTikspQHnjagFme0S3GdPUo-zw48zBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Tom Herbert <therbert@google.com>
Date: Wed, 6 Apr 2011 21:50:55 -0700

> Nice catch.
>=20
> Acked-by: Tom Herbert <therbert@google.com>
>=20
> On Wed, Apr 6, 2011 at 9:40 PM, Wei Yongjun <yjwei@cn.fujitsu.com> wr=
ote:
>> commit c6e1a0d12ca7b4f22c58e55a16beacfb7d3d8462 broken the calc
>> =A0(net: Allow no-cache copy from user on transmit)
>> of checksum, which may cause some tcp packets be dropped because
>> incorrect checksum. ssh does not work under today's net-next-2.6
>> tree.
>>
>> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied, thanks everyone.
