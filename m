From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC] ixgbe: is DCA really that good ?
Date: Wed, 6 Apr 2011 08:24:16 -0700
Message-ID: <BANLkTimSRhuVTcOX-EHx74_y3pnDdCRi8A@mail.gmail.com>
References: <1302097444.3209.85.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Brattain <ross.b.brattain@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:2479 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756456Ab1DFPYU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 11:24:20 -0400
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p36FOIlT014282
	for <netdev@vger.kernel.org>; Wed, 6 Apr 2011 08:24:19 -0700
Received: from pvh1 (pvh1.prod.google.com [10.241.210.193])
	by kpbe19.cbf.corp.google.com with ESMTP id p36FOGdG005954
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 6 Apr 2011 08:24:17 -0700
Received: by pvh1 with SMTP id 1so732539pvh.31
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2011 08:24:16 -0700 (PDT)
In-Reply-To: <1302097444.3209.85.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 6, 2011 at 6:44 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Hi guys
>
>
> In a forwarding [or RPS/RFS] setup, why should we populate cpu caches
> with full frames content ? We only need first cache line to perform
> routing [or RPS/RFS] decision.
>
DCA + accelerated RFS might make good.  But I agree that it should be
configurable.

> -> DCA should be a knob (ethtool ?) that an admin can switch off and =
on,
> port by port, not a CONFIG_IXGBE_DCA thing.
>
> Thanks
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
