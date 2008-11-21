From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [NET-NEXT v4 PATCH 1/5] ixgbe: this patch adds support for DCB to the kernel and ixgbe driver
Date: Fri, 21 Nov 2008 14:20:01 -0800
Message-ID: <9929d2390811211420q68b4f015t356ff45b5f04f363@mail.gmail.com>
References: <20081121020055.22180.24154.stgit@gitlost.lost>
	 <4926B26C.7010200@trash.net> <adaabbtgdv6.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Patrick McHardy" <kaber@trash.net>, davem@davemloft.net,
	netdev@vger.kernel.org, jeff@garzik.org,
	"Alexander Duyck" <alexander.h.duyck@intel.com>,
	"Peter P Waskiewicz Jr" <peter.p.waskiewicz.jr@intel.com>
To: "Roland Dreier" <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f11.google.com ([209.85.217.11]:57981 "EHLO
	mail-gx0-f11.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843AbYKUWUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 17:20:03 -0500
Received: by gxk4 with SMTP id 4so1045556gxk.13
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2008 14:20:02 -0800 (PST)
In-Reply-To: <adaabbtgdv6.fsf@cisco.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 21, 2008 at 9:58 AM, Roland Dreier <rdreier@cisco.com> wrote:
>  > > --- /dev/null
>  > > +++ b/net/dcb/Kconfig
>  > > @@ -0,0 +1,12 @@
>  > > +config DCB
>  > > +        tristate "Data Center Bridging support"
>
>  > A help text would be nice to have.
>
> Yes, agreed -- something giving a hint about what DCB is (per-priority
> pause, BCN) and guidance for the user that this should be enabled if
> using DCB-capable NICs and switches.
>
>  > > +
>  > > +config DCBNL
>  > > +  bool "Data Center Bridging netlink interface support"
>  > > +  depends on DCB
>  > > +  default n
>  > > +  ---help---
>  > > +    This option turns on the netlink interface
>  > > +    (dcbnl) for Data Center Bridging capable devices.
>  > > +
>  > > +    If unsure, say N.
>
> Now that I look at this config, it looks rather strange.  When does is
> ever make sense to enable DCB but not DCBNL?  How else does one
> configure all the DCB parameters except by running dcbd in userspace?
> Should there even be a separate DCBNL option at all?
>
>  - R.
> --
>

Thanks for the comments.  I am working on patches based on your
comments and should have something by Monday at the latest.

-- 
Cheers,
Jeff
