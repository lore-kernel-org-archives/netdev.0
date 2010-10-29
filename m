From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: refactor ixgbe_alloc_queues()
Date: Fri, 29 Oct 2010 00:46:40 -0700
Message-ID: <AANLkTi=Pu2RNzHrY-4=rkPkpSsOUmGMLF8DB=K7oCLLO@mail.gmail.com>
References: <1286799439.2737.21.camel@edumazet-laptop>
	<EA929A9653AAE14F841771FB1DE5A136602807B460@rrsmsx501.amr.corp.intel.com>
	<1288239858.2658.72.camel@edumazet-laptop>
	<1288267354.2649.369.camel@edumazet-laptop>
	<1288268493.27890.5.camel@jtkirshe-MOBL1>
	<1288323933.2711.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	David Miller <davem@davemloft.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Brattain, Ross B" <ross.b.brattain@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:33812 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754964Ab0J2Hql convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 03:46:41 -0400
Received: by iwn10 with SMTP id 10so3372326iwn.19
        for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 00:46:40 -0700 (PDT)
In-Reply-To: <1288323933.2711.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 28, 2010 at 20:45, Eric Dumazet <eric.dumazet@gmail.com> wr=
ote:
> Note : compiled only patch, not tested.
>
> Thanks !
>
> [PATCH] ixgbe: refactor ixgbe_alloc_queues()
>
> I noticed ring variable was initialized before allocations, and that
> memory node management was a bit ugly. We also leak memory in case of
> ring allocations error.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> =C2=A0drivers/net/ixgbe/ixgbe_main.c | =C2=A0 69 ++++++++++++--------=
-----------
> =C2=A01 file changed, 28 insertions(+), 41 deletions(-)
>

Thanks Eric.  I will add this to my queue of patches.

--=20
Cheers,
Jeff
