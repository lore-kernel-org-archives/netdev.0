From: =?UTF-8?B?QXVyw6lsaWVu?= <footplus@gmail.com>
Subject: Re: Optics (SFP) monitoring on ixgbe and igbe
Date: Thu, 8 Nov 2012 01:39:52 +0100
Message-ID: <CAPN4dA95RQ+xyvY+qo0CDc=KmaKhuqHATx_KyMjppvauYtUyzQ@mail.gmail.com>
References: <CAPN4dA8WUdox2k_F_9cYw=hR=xZHia=z3CXwy-36_t9Hh58zBg@mail.gmail.com>
 <1352318339.2725.34.camel@bwh-desktop.uk.solarflarecom.com>
Reply-To: footplus@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:45582 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753147Ab2KHAkN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 19:40:13 -0500
Received: by mail-qa0-f46.google.com with SMTP id n12so940464qat.19
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2012 16:40:12 -0800 (PST)
In-Reply-To: <1352318339.2725.34.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 7, 2012 at 8:58 PM, Ben Hutchings <bhutchings@solarflare.co=
m> wrote:
> On Wed, 2012-11-07 at 13:27 +0100, Aur=C3=A9lien wrote:
>
> We just added the ETHTOOL_GMODULEINFO and ETHTOOL_GMODULEEEPROM
> interface for this purpose.  The diagnostics obviously aren't really =
an
> EEPROM but I don't think that matters.
>
> These drivers should report a type of ETH_MODULE_SFF_8472 (assuming a
> module is present) and expose an 'EEPROM' with the real EEPROM in the
> first 256 bytes and the diagnostic registers in the next 256 bytes.
>
> Decoding of the diagnostic registers can be done in ethtool itself.
>

Hi Ben,

Thanks for this reply.

I did not see these interfaces in my searches, but from what I gather
from the code, the missing part is the actual decoding of the data in
ethtool.

As soon as I get my card installed in a test server, I'll reboot on a
kernel issued from the davem/net-next master, and will do some tests
to see if ethtool correctly sees an SFF-8472 compliant module, and has
the correct diagnostic data after the eeprom.

Then I will port the decoding part from the kernel-side patches I to
code in ethtool, and will do some basic tests.

Thanks,
Best regards,
--=20
Aur=C3=A9lien Guillaume
