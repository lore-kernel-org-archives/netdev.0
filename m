From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ATM: CVE-2008-5079: multiple listen()s on same socket
 corrupts the vcc table
Date: Thu, 04 Dec 2008 15:00:11 -0800 (PST)
Message-ID: <20081204.150011.93825471.davem@davemloft.net>
References: <200812041725.mB4HP5rS031103@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eteo@redhat.com, stable@kernel.org
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58194
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752681AbYLDXAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 18:00:11 -0500
In-Reply-To: <200812041725.mB4HP5rS031103@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Date: Thu, 04 Dec 2008 12:25:05 -0500

> please apply to net-next-2.6 and consider for net-2.6 if possible.
> 
> thanks!
> 
> commit 8c5629cfd33e2e8275aae98bbf62a98bf59bc7e8
> Author: Chas Williams - CONTRACTOR <chas@relax.cmf.nrl.navy.mil>
> Date:   Thu Dec 4 12:14:42 2008 -0500
> 
>     ATM: CVE-2008-5079: duplicate listen() on socket corrupts the vcc table
>     
>     As reported by Hugo Dias that it is possible to cause a local denial
>     of service attack by calling the svc_listen function twice on the same
>     socket and reading /proc/net/atm/*vc
>     
>     Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

Applied to net-2.6, thanks Chas.
