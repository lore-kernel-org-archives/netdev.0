From: thomas yang <lampsu@gmail.com>
Subject: Re: Ethernet CRC questions
Date: Wed, 30 Dec 2009 13:53:09 +0800
Message-ID: <f4f837ab0912292153l7086b631o6e0012d9049eecdb@mail.gmail.com>
References: <f4f837ab0912290917h626bcfecy34fe095a878e733c@mail.gmail.com>
	 <1262108376.5941.5.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:60763 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053AbZL3FxK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2009 00:53:10 -0500
Received: by pzk1 with SMTP id 1so3888780pzk.33
        for <netdev@vger.kernel.org>; Tue, 29 Dec 2009 21:53:09 -0800 (PST)
In-Reply-To: <1262108376.5941.5.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/12/30 Ben Hutchings <bhutchings@solarflare.com>:
> On Wed, 2009-12-30 at 01:17 +0800, thomas yang wrote:
>> How does Linux =A0generate Ethernet CRC ?
>> by the hardware (Ethernet controller) =A0or =A0use crc32_le() /
>> crc32_be() =A0 =A0 ( lib/crc32.c ) =A0?
>>
>> P.S. =A0 my =A0network card is =A0rtl8139d =A0, use =A08139too drive=
r
>
> The Ethernet frame CRC is normally generated and verified in hardware=
=2E
> These library functions are needed for the few MACs that don't, or wh=
ere
> the same CRC function is used for some other purpose (e.g. as a hash
> function for multicast filtering).
>

Does the Ethernet frame CRC (generate and verify in hardware)  make
the TX / RX  rate  a little smaller , and a longer end-to-end  delay ?
 Could I disable CRC appending / verifying  in the network card driver
  on all of my nodes (machines) ?

Thanks.



--
Thomas
