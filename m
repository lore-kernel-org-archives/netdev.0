From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH net-next] e1000: Omit private ndo_get_stats function
Date: Thu, 23 Mar 2017 00:11:39 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B8C5CCF4B@ORSMSX101.amr.corp.intel.com>
References: <20170215110811.29976-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "Joe Perches" <joe@perches.com>
To: Tobias Klauser <tklauser@distanz.ch>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54063 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752412AbdCWALl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 22 Mar 2017 20:11:41 -0400
In-Reply-To: <20170215110811.29976-1-tklauser@distanz.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Tobias Klauser
> Sent: Wednesday, February 15, 2017 3:08 AM
> To: netdev@vger.kernel.org
> Cc: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>; intel-wired-
> lan@lists.osuosl.org; Joe Perches <joe@perches.com>
> Subject: [PATCH net-next] e1000: Omit private ndo_get_stats function
>=20
> e1000_get_stats() just returns dev->stats so we can leave it
> out altogether and let dev_get_stats() do the job.
>=20
> Suggested-by: Joe Perches <joe@perches.com>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c | 15 ---------------
>  1 file changed, 15 deletions(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
