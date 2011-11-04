From: Greg KH <greg@kroah.com>
Subject: Re: [stable] net: Handle different key sizes between address
 families in flow cache
Date: Fri, 4 Nov 2011 14:24:39 -0700
Message-ID: <20111104212439.GA27324@kroah.com>
References: <20111101185022.b156ea957baf286f1bf00f9c@freescale.com>
 <20111101.203430.110242050755204948.davem@davemloft.net>
 <20111103135851.2229247682ec040d653479e1@freescale.com>
 <20111103.224329.2276058062630695656.davem@davemloft.net>
 <20111104144659.3e0a30afffffd9dd73cf740e@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, stable@vger.kernel.org,
	eric.dumazet@gmail.com, zheng.z.yan@intel.com,
	netdev@vger.kernel.org, David Ward <david.ward@ll.mit.edu>
To: Kim Phillips <kim.phillips@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5.smtp.messagingengine.com ([66.111.4.29]:57993 "EHLO
	out5.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754574Ab1KDV1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 17:27:37 -0400
Content-Disposition: inline
In-Reply-To: <20111104144659.3e0a30afffffd9dd73cf740e@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 04, 2011 at 02:46:59PM -0500, Kim Phillips wrote:
> commit aa1c366e4febc7f5c2b84958a2dd7cd70e28f9d0 upstream.
>=20
> With the conversion of struct flowi to a union of AF-specific structs=
, some
> operations on the flow cache need to account for the exact size of th=
e key.
>=20
> Signed-off-by: David Ward <david.ward@ll.mit.edu>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> Cc: stable@vger.kernel.org # v3.0.x
> ---
> This patch is the result of a clean cherry-pick onto v3.0.8.
> It restores IPSec fwding performance from ~4kpps back to ~44kpps on
> a P2020DS board.

Too bad you forgot to build this patch after you applied it:
  CC      init/main.o
In file included from include/linux/security.h:39:0,
                 from init/main.c:32:
include/net/flow.h: In function =E2=80=98flow_key_size=E2=80=99:
include/net/flow.h:174:3: error: size of unnamed array is negative
include/net/flow.h:177:3: error: size of unnamed array is negative

Please be kind to your poor over-worked stable kernel maintainer and do
the decent thing and TEST YOUR PATCH before you ask him to accept it.

bah, I think it's time for the weekend to start a bit earlier than norm=
al...

greg k-h
