From: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Subject: Re: [PATCH] Bluetooth: Pre-initialize variables in read_local_oob_ext_data_complete()
Date: Fri, 17 Apr 2015 22:03:29 +0200
Message-ID: <CAMuHMdUxnrg1BVoFpKExzGHKj2aOmYGp+wChhMbPfmWvMzQT=Q@mail.gmail.com>
References: <1429212265-26750-1-git-send-email-geert@linux-m68k.org>
	<A962A040-4EB5-4AE6-A790-A8767185172B@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	BlueZ development <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <A962A040-4EB5-4AE6-A790-A8767185172B-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Marcel,

On Thu, Apr 16, 2015 at 10:34 PM, Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>=
 wrote:
>> net/bluetooth/mgmt.c: In function =E2=80=98read_local_oob_ext_data_c=
omplete=E2=80=99:
>> net/bluetooth/mgmt.c:6474: warning: =E2=80=98r256=E2=80=99 may be us=
ed uninitialized in this function
>> net/bluetooth/mgmt.c:6474: warning: =E2=80=98h256=E2=80=99 may be us=
ed uninitialized in this function
>> net/bluetooth/mgmt.c:6474: warning: =E2=80=98r192=E2=80=99 may be us=
ed uninitialized in this function
>> net/bluetooth/mgmt.c:6474: warning: =E2=80=98h192=E2=80=99 may be us=
ed uninitialized in this function
>>
>> While these are false positives, the code can be shortened by
>> pre-initializing the hash table pointers and eir_len. This has the s=
ide
>> effect of killing the compiler warnings.
>
> can you be a bit specific on which compiler version is this. I fixed =
one occurrence that seemed valid. However in this case the compiler see=
ms to be just plain stupid. On a gcc 4.9, I am not seeing these for exa=
mple.

gcc 4.1.2. As there were too many false positives, these warnings were
disabled in later versions (throwing away the children with the bad wat=
er).

If you don't like my patch, just drop it. I only look at newly
introduced warnings
of this kind anyway.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
                                -- Linus Torvalds
