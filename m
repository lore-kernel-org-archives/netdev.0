From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: Re: [PATCH 03/11] cirrus/mac89x0: print MAC via printk format specifier
Date: Wed, 29 Feb 2012 08:22:58 +0100
Message-ID: <201202290822.59640.danny.kukawka@bisect.de>
References: <1330091162-8141-4-git-send-email-danny.kukawka@bisect.de> <20120228.154914.662485432055205683.davem@davemloft.net> <CAMuHMdUudso1YpukfxvGdb2fAYZBJewTgQEh-aU_KB0-U2o6WQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jeffrey.t.kirsher@intel.com,
	jpirko@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdUudso1YpukfxvGdb2fAYZBJewTgQEh-aU_KB0-U2o6WQ@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Dienstag, 28. Februar 2012, Geert Uytterhoeven wrote:
> Hi David,
>
> 2012/2/28 David Miller <davem@davemloft.net>:
> > From: Geert Uytterhoeven <geert@linux-m68k.org>
> > Date: Tue, 28 Feb 2012 21:45:30 +0100
> >
> >> drivers/net/ethernet/cirrus/mac89x0.c: In function =E2=80=98set_ma=
c_address=E2=80=99:
> >> drivers/net/ethernet/cirrus/mac89x0.c:597: warning: dereferencing
> >> =E2=80=98void *=E2=80=99 pointer
> >> drivers/net/ethernet/cirrus/mac89x0.c:597: error: request for memb=
er
> >> =E2=80=98sa_data=E2=80=99 in something not a structure or union
> >> drivers/net/ethernet/cirrus/mac89x0.c:600: warning: dereferencing
> >> =E2=80=98void *=E2=80=99 pointer
> >> drivers/net/ethernet/cirrus/mac89x0.c:600: error: request for memb=
er
> >> =E2=80=98sa_data=E2=80=99 in something not a structure or union
> >> drivers/net/ethernet/cirrus/mac89x0.c:595: warning: unused variabl=
e
> >> =E2=80=98saddr=E2=80=99
> >
> > Thanks, I've fixed this as follows and pushed to net-next:
> >
> > --------------------
> > mac89x0: Fix build error.
> >
> > Need to use the new 'saddr' variable not the void 'addr' in
> > set_mac_address().
> >
> > Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
> > Signed-off-by: David S. Miller <davem@davemloft.net>
Thanks for the fix!

> Thanks, that fixed the build.
>
> What about the is_valid_ether_addr() check?

If you mean the discussion about checking if the MAC is valid in
=2Endo_set_mac_address, I'm on that issue and will hopefully send a pat=
ch soon.

Danny
