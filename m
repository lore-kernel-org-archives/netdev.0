From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [net-next 5/5] igbvf: convert to ndo_fix_features
Date: Mon, 17 Oct 2011 00:08:19 +0200
Message-ID: <20111016220819.GA25318@rere.qmqm.pl>
References: <1318797423-19897-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1318797423-19897-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:35046 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752598Ab1JPWIW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Oct 2011 18:08:22 -0400
Content-Disposition: inline
In-Reply-To: <1318797423-19897-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 16, 2011 at 01:37:03PM -0700, Jeff Kirsher wrote:
> From: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
>=20
> Private rx_csum flags are now duplicate of netdev->features & NETIF_F=
_RXCSUM.
> Removing this needs deeper surgery.
>=20
> Things noticed:
>  - HW VLAN acceleration probably can be toggled, but it's left as is
>  - the resets on RX csum offload change can probably be avoided
>  - there is A LOT of copy-and-pasted code here
>=20
> Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
[patch cut]

Great news!

This is the last brick needed for ethtool cleanup. After Dave takes thi=
s
one in I'll start dusting off the patches that introduce netif_features=
_t
and extend it to 64 bits.

Best Regards,
Micha=B3 Miros=B3aw
