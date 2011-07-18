From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net-next v3 af-packet 1/2] Enhance af-packet to provide
 (near zero)lossless packet capture functionality.
Date: Mon, 18 Jul 2011 08:49:30 -0400
Message-ID: <CAAsGZS5b9X5HW=_JjfahbXpi9f4H5iYGeY9-+wBjP+=c-MDj4w@mail.gmail.com>
References: <1310959610-1688-1-git-send-email-loke.chetan@gmail.com>
	<1310959610-1688-2-git-send-email-loke.chetan@gmail.com>
	<1310971114.2509.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:36153 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751666Ab1GRMtb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 08:49:31 -0400
Received: by pvg12 with SMTP id 12so2951741pvg.19
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2011 05:49:30 -0700 (PDT)
In-Reply-To: <1310971114.2509.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 18, 2011 at 2:38 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le dimanche 17 juillet 2011 =C3=A0 23:26 -0400, Chetan Loke a =C3=A9c=
rit :
>> Signed-off-by: Chetan Loke <loke.chetan@gmail.com>
>> ---
>> =C2=A0include/linux/if_packet.h | =C2=A0125 ++++++++++++++++++++++++=
+++++++++++++++++++++
>> =C2=A01 files changed, 125 insertions(+), 0 deletions(-)
>
>>
>> +struct tpacket3_hdr {
>> + =C2=A0 =C2=A0 __u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tp_status;
>> + =C2=A0 =C2=A0 __u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tp_next_off=
set;
>> + =C2=A0 =C2=A0 __u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tp_len;
>> + =C2=A0 =C2=A0 __u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tp_snaplen;
>> + =C2=A0 =C2=A0 __u16 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tp_mac;
>> + =C2=A0 =C2=A0 __u16 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tp_net;
>> + =C2=A0 =C2=A0 __u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tp_sec;
>> + =C2=A0 =C2=A0 __u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tp_nsec;
>> + =C2=A0 =C2=A0 __u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tp_rxhash;
>> + =C2=A0 =C2=A0 __u16 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tp_vlan_tci=
;
>> + =C2=A0 =C2=A0 __u16 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tp_padding;
>> + =C2=A0 =C2=A0 __u32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tp_next_off=
set;
>> +};
>
> Srange, I see tp_next_offset twice in tpacket3_hdr ?

Sorry, I was trying some last minute fancy prefetch changes. So I
bubbled up the field on my test box but somehow missed the cleanup on
the dev-box.
Will wait for a day to gather some more comments and then re-send the p=
atch.

Chetan Loke
