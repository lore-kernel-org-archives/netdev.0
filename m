From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] ixgbe: make macvlan on PF working when SRIOV is
	enabled
Date: Tue, 25 May 2010 11:37:53 -0700
Message-ID: <AANLkTinIsgRsLHFopaYxsUxLwEqr8SpOEWv6P9uFKzYh@mail.gmail.com>
References: <1274806509.18023.58.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gregory.v.rose@intel.com,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:39928 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932294Ab0EYShy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 14:37:54 -0400
In-Reply-To: <1274806509.18023.58.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 25, 2010 at 09:55, Shirley Ma <mashirle@us.ibm.com> wrote:
> When SRIOV is enabled, if we create macvlan on PF and load the VF dri=
ver in host
> domain, when macvlan/PF and VF interfaces are all up, the macvlan inc=
oming network
> traffics are directed to VF interface not PF interface. This patch ha=
s fixed this
> issue.
>
> Signed-off-by: Shirley Ma <xma@us.ibm.com>
> ---
> =C2=A0drivers/net/ixgbe/ixgbe_common.c | =C2=A0 26 ++++++++++++++++--=
--------
> =C2=A01 files changed, 16 insertions(+), 10 deletions(-)
>

Thanks, I have added the patch to my queue.

--=20
Cheers,
Jeff
