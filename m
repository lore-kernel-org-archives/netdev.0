From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC][PATCH]: e1000e: If ASPM L0s needs to be disabled, do it
 prior to enabling device
Date: Tue, 22 Mar 2011 21:08:26 -0700
Message-ID: <AANLkTik0XBfbYuSa1v0v4vAdGAYXsn1c7qPpUJU593C8@mail.gmail.com>
References: <20110322194437.3043.97757.sendpatchset@nchumbalkar.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	bruce.w.allan@intel.com
To: Naga Chumbalkar <nagananda.chumbalkar@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38387 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720Ab1CWEI1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 00:08:27 -0400
Received: by fxm17 with SMTP id 17so7006711fxm.19
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2011 21:08:26 -0700 (PDT)
In-Reply-To: <20110322194437.3043.97757.sendpatchset@nchumbalkar.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 22, 2011 at 12:48, Naga Chumbalkar
<nagananda.chumbalkar@hp.com> wrote:
> If ASPM L0s needs to be disabled due to HW errata, do it prior to
> "enabling" the device. This way if the kernel ever defaults its
> aspm_policy to POLICY_POWERSAVE, then the e1000e driver will get a
> chance to disable ASPM on the misbehaving device *prior* to calling
> pci_enable_device_mem(). This will be useful in situations
> where the BIOS indicates ASPM support on the server by clearing the
> ACPI FADT "ASPM Controls" bit.
>
> Note:
> The kernel (2.6.38) currently uses the BIOS "default" as its aspm_pol=
icy.
> However, Linux distros can diverge from that and set the default to "=
powersave".
>
> Signed-off-by: Naga Chumbalkar <nagananda.chumbalkar@hp.com>
> Cc: Bruce Allan <bruce.w.allan@intel.com>
>
> ---
> =C2=A0drivers/net/e1000e/82571.c =C2=A0| =C2=A0 10 +++++-----
> =C2=A0drivers/net/e1000e/e1000.h =C2=A0| =C2=A0 =C2=A01 +
> =C2=A0drivers/net/e1000e/netdev.c | =C2=A0 25 +++++++++++++++++++++--=
--
> =C2=A03 files changed, 27 insertions(+), 9 deletions(-)
>

I have added this patch to my queue of e1000e patches.

--=20
Cheers,
Jeff
