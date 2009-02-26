From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 0/7] I/OAT update
Date: Thu, 26 Feb 2009 02:31:24 -0800
Message-ID: <9929d2390902260231p72aacdf3j489a8a9e67dbb659@mail.gmail.com>
References: <20090226100327.3615.21419.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dan.j.williams@intel.com, snakebyte@gmx.de,
	shannon.nelson@intel.com, jeffrey.t.krisher@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Maciej Sosnowski <maciej.sosnowski@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.244]:35101 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753730AbZBZKb2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 05:31:28 -0500
In-Reply-To: <20090226100327.3615.21419.stgit@linux.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2009 at 2:04 AM, Maciej Sosnowski
<maciej.sosnowski@intel.com> wrote:
> This patch series updates ioatdma driver
> with a couple of fixes and workarounds,
> including copybreak modification,
> plus some cleanup like copyright dates update.
>
> Maciej Sosnowski (6):
> =C2=A0 =C2=A0I/OAT: add verification for proper APICID_TAG_MAP settin=
g by BIOS
> =C2=A0 =C2=A0I/OAT: do not set DCACTRL_CMPL_WRITE_ENABLE for I/OAT ve=
r.3
> =C2=A0 =C2=A0I/OAT: fail initialization on zero channels detection
> =C2=A0 =C2=A0I/OAT: cancel watchdog before dma remove
> =C2=A0 =C2=A0I/OAT: set tcp_dma_copybreak to 256k for I/OAT ver.3
> =C2=A0 =C2=A0I/OAT: update driver version and copyright dates
>
> Eric Sesterhenn (1):
> =C2=A0 =C2=A0I/OAT: list usage cleanup
>
> =C2=A0drivers/dca/dca-core.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0=
 =C2=A02 -
> =C2=A0drivers/dma/ioat.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0| =C2=A0 =C2=A02 -
> =C2=A0drivers/dma/ioat_dca.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0=
 26 ++++++++++++++++++++++++-
> =C2=A0drivers/dma/ioat_dma.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0=
 31 ++++++++++++++++++------------
> =C2=A0drivers/dma/ioatdma.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0=
 =C2=A08 ++++---
> =C2=A0drivers/dma/ioatdma_hw.h =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=
=A02 -
> =C2=A0drivers/dma/ioatdma_registers.h | =C2=A0 =C2=A02 -
> =C2=A07 files changed, 53 insertions(+), 20 deletions(-)
>
> --
> Maciej
> --
>

Dave - FYI, my Acked-by email on this patch series is incorrect.  It
should be jeffrey.t.kirsher@intel.com not "krisher".

--=20
Cheers,
Jeff
