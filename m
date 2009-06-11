From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: fix mismatched dma map/unmap size
Date: Thu, 11 Jun 2009 14:38:47 -0700
Message-ID: <9929d2390906111438u15d20835u872fd41c99c7e03f@mail.gmail.com>
References: <20090609171151.GM20823@sequoia.sous-sol.org>
	 <20090611.032024.218154973.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: chrisw@sous-sol.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:64598 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbZFKVis convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 17:38:48 -0400
Received: by an-out-0708.google.com with SMTP id d40so3355942and.1
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 14:38:49 -0700 (PDT)
In-Reply-To: <20090611.032024.218154973.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 11, 2009 at 3:20 AM, David Miller<davem@davemloft.net> wrot=
e:
> From: Chris Wright <chrisw@sous-sol.org>
> Date: Tue, 9 Jun 2009 10:11:51 -0700
>
>> DMA buffer is mapped w/ NET_IP_ALIGN accounted, unmapped w/out.
>> Dma debugging generates this warning. =C2=A0Simple fix below.
>>
>> [ =C2=A0 76.356509] ixgbe 0000:04:00.0: DMA-API: device driver frees=
 DMA
>> memory with different size [device address=3D0x00000000fff7f022] [ma=
p
>> size=3D1524 bytes] [unmap size=3D1522 bytes]
>> ...
>> [ =C2=A0 76.440333] =C2=A0[<ffffffffa000247f>] ixgbe_clean_rx_irq+0x=
123/0x41b [ixgbe]
>> ...
>> [ =C2=A0 76.551151] Mapped at:
>> [ =C2=A0 76.553582] =C2=A0[<ffffffff811bd745>] debug_dma_map_page+0x=
4d/0xf8
>> [ =C2=A0 76.559584] =C2=A0[<ffffffffa00012d4>] ixgbe_alloc_rx_buffer=
s+0x204/0x2af [ixgbe]
>>
>> Signed-off-by: Chris Wright <chrisw@sous-sol.org>
>> ---
>> Fix is against v2.6.30-rc8-73-g3af968e, but still applies to net-nex=
t.
>
> I'll leave this for Jeff to suck into his queue. =C2=A0 Thanks Chris.
> --

I have this in my queue, thanks.

--=20
Cheers,
Jeff
