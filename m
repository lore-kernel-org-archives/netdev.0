From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 03/11] cirrus/mac89x0: print MAC via printk format specifier
Date: Tue, 28 Feb 2012 22:00:50 +0100
Message-ID: <CAMuHMdUudso1YpukfxvGdb2fAYZBJewTgQEh-aU_KB0-U2o6WQ@mail.gmail.com>
References: <1330091162-8141-4-git-send-email-danny.kukawka@bisect.de>
	<CAMuHMdXAwgtwbCV_=qJnrs=YPZksoEBkjnQB=JbR7fc+UyKdzw@mail.gmail.com>
	<CAMuHMdW0Oh7h8tv85ScgHB50vMaZSU7S3cPJRsChnRe2sNL_kA@mail.gmail.com>
	<20120228.154914.662485432055205683.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: danny.kukawka@bisect.de, dkukawka@suse.de,
	jeffrey.t.kirsher@intel.com, jpirko@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120228.154914.662485432055205683.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

2012/2/28 David Miller <davem@davemloft.net>:
> From: Geert Uytterhoeven <geert@linux-m68k.org>
> Date: Tue, 28 Feb 2012 21:45:30 +0100
>
>> drivers/net/ethernet/cirrus/mac89x0.c: In function =E2=80=98set_mac_=
address=E2=80=99:
>> drivers/net/ethernet/cirrus/mac89x0.c:597: warning: dereferencing
>> =E2=80=98void *=E2=80=99 pointer
>> drivers/net/ethernet/cirrus/mac89x0.c:597: error: request for member
>> =E2=80=98sa_data=E2=80=99 in something not a structure or union
>> drivers/net/ethernet/cirrus/mac89x0.c:600: warning: dereferencing
>> =E2=80=98void *=E2=80=99 pointer
>> drivers/net/ethernet/cirrus/mac89x0.c:600: error: request for member
>> =E2=80=98sa_data=E2=80=99 in something not a structure or union
>> drivers/net/ethernet/cirrus/mac89x0.c:595: warning: unused variable =
=E2=80=98saddr=E2=80=99
>
> Thanks, I've fixed this as follows and pushed to net-next:
>
> --------------------
> mac89x0: Fix build error.
>
> Need to use the new 'saddr' variable not the void 'addr' in
> set_mac_address().
>
> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Thanks, that fixed the build.

What about the is_valid_ether_addr() check?

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds
