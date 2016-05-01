From: Ran Shalit <ranshalit@gmail.com>
Subject: Re: Q: How to disable vlan strip in Intel igb driver ?
Date: Sun, 1 May 2016 21:48:03 +0300
Message-ID: <CAJ2oMhJp9M93QujnPYmp5CQkt-tx8P-uRCveiMEkDRLrcZmNhg@mail.gmail.com>
References: <CAJ2oMhKyMbgLZiGSGQxRGVdbGARvMHeO3=vpgO0uOzOBqvf79Q@mail.gmail.com>
	<afa69dcb-0905-a556-0208-49a2363ae818@fri.uniza.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com
To: =?UTF-8?Q?Peter_Pal=C3=BAch?= <Peter.Paluch@fri.uniza.sk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:37784 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043AbcEASsE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 14:48:04 -0400
Received: by mail-ig0-f177.google.com with SMTP id s8so59152134ign.0
        for <netdev@vger.kernel.org>; Sun, 01 May 2016 11:48:04 -0700 (PDT)
In-Reply-To: <afa69dcb-0905-a556-0208-49a2363ae818@fri.uniza.sk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Ran
>
> You should be able to turn off the offload by setting
> "rx-vlan-offload" to "off" via "ethtool -K".
>
> - Alex

Alex,
I don't see rx-vlan-offload option in my ethtool. strange, maybe it is
not available in all ethtool versions ?



On Sun, May 1, 2016 at 9:22 PM, Peter Pal=C3=BAch <Peter.Paluch@fri.uni=
za.sk> wrote:
> Ran,
>
> How are you accessing the VLAN tag information - and how do you know =
that
> the VLAN tag is not being passed through? Are you using AF_PACKET soc=
ket in
> your application?
>
> Best regards,
> Peter
>
>
Hi Peter,

Yes, I'm using AF_PACKET (I can't validate it now for 100%, but I
quite sure about it).
I'm accessing the ethernet header, and it always gives me non extended
ethernet header (without vlan information).
I can see the vlan tag in vlan_tci field in sk_buff, but this is not
exactly what I need, I need the header AS-IS with the original
(extended) ethernet header.

Thanks.
Ran
>
> On 01.05.2016 15:13, Ran Shalit wrote:
>>
>> Hello,
>>
>>
>> I am using intel igb driver in Linux.
>>
>> The driver strip the packet from vlan inofmation. But we need this
>> information in the packet.
>>
>> We tried to change build flag, or see if there is any feature with
>> ethtool that can disable this feature, but nothing helps.
>>
>>
>> Is there any way to achive this ?
>>
>> Regards,
>>
>> Ran
>
>
