From: Ricardo Farrington <Ricardo.Farrington@cavium.com>
Subject: RE: [PATCH net-next] liquidio: update debug console logging mechanism
Date: Mon, 14 Aug 2017 16:28:50 +0000
Message-ID: <CY1PR0701MB1961883A407496B03A8FD870EC8C0@CY1PR0701MB1961.namprd07.prod.outlook.com>
References: <20170812014314.GA1012@felix-thinkpad.cavium.com>
 <20170813055549.GO24282@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>,
        "Chickles, Derek" <Derek.Chickles@cavium.com>,
        "Burla, Satananda" <Satananda.Burla@cavium.com>
To: Leon Romanovsky <leon@kernel.org>,
        "Manlunas, Felix" <Felix.Manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0087.outbound.protection.outlook.com ([104.47.37.87]:33673
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752527AbdHNQ2y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 12:28:54 -0400
In-Reply-To: <20170813055549.GO24282@mtr-leonro.local>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Leon - the code to which this patch applies handles a data stream from o=
ur card's firmware to the host (over PCI).
There are device-specific registers which are accessed to transfer log data=
 from our firmware to the host.
I don't think there is kernel code that we could use to perform this; this =
is not general purpose host driver logging.

Rick

-----Original Message-----
From: Leon Romanovsky [mailto:leon@kernel.org]=20
Sent: Saturday, August 12, 2017 10:56 PM
To: Manlunas, Felix <Felix.Manlunas@cavium.com>
Cc: davem@davemloft.net; netdev@vger.kernel.org; Vatsavayi, Raghu <Raghu.Va=
tsavayi@cavium.com>; Chickles, Derek <Derek.Chickles@cavium.com>; Burla, Sa=
tananda <Satananda.Burla@cavium.com>; Ricardo Farrington <Ricardo.Farringto=
n@cavium.com>
Subject: Re: [PATCH net-next] liquidio: update debug console logging mechan=
ism

On Fri, Aug 11, 2017 at 06:43:14PM -0700, Felix Manlunas wrote:
> From: Rick Farrington <ricardo.farrington@cavium.com>
>
> - remove logging dependency upon global func=20
> octeon_console_debug_enabled()
> - abstract debug console logging using console structure (via function pt=
r)
>   to allow for more flexible logging
>
> Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> ---
>  drivers/net/ethernet/cavium/liquidio/lio_main.c    | 44 ++++++++++++++++=
+-
>  .../net/ethernet/cavium/liquidio/octeon_console.c  | 54 ++++++++++++++--=
------
>  .../net/ethernet/cavium/liquidio/octeon_device.h   | 17 +++++--
>  3 files changed, 90 insertions(+), 25 deletions(-)
>

I'm probably missing something important, but why do you need your custom c=
onsole implementation if kernel is full of such built-in options?

Thanks
