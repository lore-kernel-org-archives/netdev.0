From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 PATCH 2/3] e1000e: reset PHY after errors detected
 on 82574 Si
Date: Thu, 30 Sep 2010 16:00:47 -0700
Message-ID: <AANLkTimfkdS0EoK9PkkNghV8ws_YUS+46D2Vu1ke-fP2@mail.gmail.com>
References: <20100930073814.13378.4212.stgit@localhost.localdomain>
	<20100930073909.13378.34776.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:52986 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751759Ab0I3XAs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 19:00:48 -0400
Received: by iwn5 with SMTP id 5so3005803iwn.19
        for <netdev@vger.kernel.org>; Thu, 30 Sep 2010 16:00:48 -0700 (PDT)
In-Reply-To: <20100930073909.13378.34776.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 30, 2010 at 00:39, Jeff Kirsher <jeffrey.t.kirsher@intel.co=
m> wrote:
> From: Carolyn Wyborny <carolyn.wyborny@intel.com>
>
> Some errors can be induced in the PHY via environmental testing
> (specifically extreme temperature changes and electro static
> discharge testing), and in the case of the PHY hanging due to
> this input, this detects the problem and resets to continue.
> This issue only applies to 82574 silicon.
>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>
> =C2=A0drivers/net/e1000e/82571.c =C2=A0| =C2=A0 40 ++++++++++++++++++=
+++++++++++++++++++++-
> =C2=A0drivers/net/e1000e/e1000.h =C2=A0| =C2=A0 =C2=A03 +++
> =C2=A0drivers/net/e1000e/netdev.c | =C2=A0 25 +++++++++++++++++++++++=
++
> =C2=A03 files changed, 67 insertions(+), 1 deletions(-)
>

Dave - please ignore this patch.  An issue was found with this patch.

--=20
Cheers,
Jeff
