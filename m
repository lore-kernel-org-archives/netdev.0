From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 PATCH 3/3] e1000e: update to workaround for jumbo
	frames on 82577
Date: Mon, 2 Aug 2010 17:36:56 -0700
Message-ID: <AANLkTi=TvRmXxJu1+y9B8x7G55Ur9wNhYzDZ8Q=+HJRJ@mail.gmail.com>
References: <20100803002622.4179.31850.stgit@localhost.localdomain>
	<20100803002748.4179.85660.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:43041 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611Ab0HCAg5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 20:36:57 -0400
Received: by iwn7 with SMTP id 7so4579135iwn.19
        for <netdev@vger.kernel.org>; Mon, 02 Aug 2010 17:36:56 -0700 (PDT)
In-Reply-To: <20100803002748.4179.85660.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 2, 2010 at 17:27, Jeff Kirsher <jeffrey.t.kirsher@intel.com=
> wrote:
> From: Bruce Allan <bruce.w.allan@intel.com>
>
> For OEM systems with this part that also has Spread Spectrum Clocking=
 (SSC)
> enabled in the BIOS, there is an Rx performance issue with 4K jumbo f=
rames.
> Leaving the defaults in PHY page 770 register 26 resolves the issue, =
and
> does not negatively impact jumbo frames on systems with SSC disabled.
>
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>
> =C2=A0drivers/net/e1000e/netdev.c | =C2=A0 =C2=A05 -----
> =C2=A01 files changed, 0 insertions(+), 5 deletions(-)
>

Please disregard this patch, it was sent out accidentally (my bad).
During testing issues were found and changes need to be made to this
patch.

--=20
Cheers,
Jeff
