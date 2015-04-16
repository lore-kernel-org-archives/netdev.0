From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] dsa: mv88e6xxx: Fix error handling in mv88e6xxx_set_port_state
Date: Thu, 16 Apr 2015 20:51:08 +0200
Message-ID: <CAMuHMdVEbXGLR_svG9tHVMSvEOfajNX6GxAo113n2TfvGSRcwA@mail.gmail.com>
References: <1429161162-2028-1-git-send-email-linux@roeck-us.net>
	<552FBD4C.4070405@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:33393 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753428AbbDPSvJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 14:51:09 -0400
In-Reply-To: <552FBD4C.4070405@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 16, 2015 at 3:46 PM, Guenter Roeck <linux@roeck-us.net> wro=
te:
> On 04/15/2015 10:12 PM, Guenter Roeck wrote:
>>
>> Return correct error code if _mv88e6xxx_reg_read returns an error.
>>
>> Fixes: facd95b2e0ec0 ("net: dsa: mv88e6xxx: Add Hardware bridging
>> support")
>> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
>
>
> I should have given proper credit.
>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
>
> For the curious, neither W=3D1, W=3D2, C-1, C=3D2, nor sparse report =
this problem,
> at least not with gcc 4.9.1.

Good old gcc 4.1.2 (which I still use for m68k builds, and won't retire=
 anytime
soon as it finds real bugs in every new kernel release) says:

    drivers/net/dsa/mv88e6xxx.c: In function =E2=80=98mv88e6xxx_set_por=
t_state=E2=80=99:
    drivers/net/dsa/mv88e6xxx.c:905: warning: =E2=80=98ret=E2=80=99 may=
 be used
uninitialized in this function

Even after your patch, as it missed one case (patch sent).

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
