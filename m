From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Fri, 27 Apr 2012 11:22:49 +0200
Message-ID: <CA+icZUVAK3NHmbG5kR1KhqGe9mAimWWzLz-MfXOXbyry3Sz73w@mail.gmail.com>
References: <1335517711-6522-1-git-send-email-sedat.dilek@gmail.com>
	<20120427091405.GS3157@wantstofly.org>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120427091405.GS3157@wantstofly.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 27, 2012 at 11:14 AM, Lennert Buytenhek
<buytenh@wantstofly.org> wrote:
> On Fri, Apr 27, 2012 at 11:08:31AM +0200, Sedat Dilek wrote:
>
>> User lautriv asked for belkin N-1 WLAN device support on IRC.
>>
>> Further informations from lautriv:
>> * marvell 80W8031, card-id 11ab:2a02
>> * Debian/sid 3.2.x
>>
>> On [1] I found a report by Jim Cromie concerning same PCI device-id:
>>
>> 00:0e.0 Ethernet controller [0200]: Marvell Technology Group Ltd.
>> 88W8361 [TopDog] 802.11n Wireless [11ab:2a02] (rev 03)
>> =C2=A0 =C2=A0 =C2=A0 Subsystem: Marvell Technology Group Ltd. 88W836=
1 [TopDog] 802.11n Wireless [11ab:2a02]
>>
>> So, let's add 0x2a02 to PCI device table.
>
> Let's not. =C2=A0There's no firmware for the 8361 that implements the
> firmware interface currently implemented by the mwl8k driver, so
> this is pretty useless.
>
>
>> [1] http://www.spinics.net/lists/newbies/msg46601.html
>
> From that link:
>
> | I have a card which modprobes, despite a PCI-ID mismatch
> |
> | [...]
> |
> | Given the pci-id mismatch shouldnt this just fail to modprobe ?
>
> No. =C2=A0That's not a bug -- you are free to load drivers for hardwa=
re
> not currently in your system.
>
>
>> =C2=A0static DEFINE_PCI_DEVICE_TABLE(mwl8k_pci_id_table) =3D {
>> + =C2=A0 =C2=A0 { PCI_VDEVICE(MARVELL, 0x2a02), .driver_data =3D MWL=
8363, },
>> =C2=A0 =C2=A0 =C2=A0 { PCI_VDEVICE(MARVELL, 0x2a0a), .driver_data =3D=
 MWL8363, },
>
> A 8361 is certainly not a 8363.

Damn, I got confused by all the numbers. More coffee.
Thanks for the clarification. I will inform the user on IRC.
Sorry, for the noise.

Are you planning to or even working on support (for) 8361 devices?

- Sedat -
