From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: [PATCH 2.6.16-rc5] S2io: Receive packet classification and steering mechanisms
Date: Thu, 20 Apr 2006 16:41:39 -0700
Message-ID: <MAEEKMLDLDFEGKHNIJHIIEKBCDAA.ravinandan.arakali@neterion.com>
References: <200604200251.14309.ak@suse.de>
Reply-To: <ravinandan.arakali@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <jgarzik@pobox.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:14768 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S1751285AbWDTXlj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 19:41:39 -0400
To: "Andi Kleen" <ak@suse.de>
In-Reply-To: <200604200251.14309.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi,
The driver will be polling(listening) to netlink for
any configuration requests. We could release the user
tools but not sure where(in the tree) they would reside.

Thanks,
Ravi

-----Original Message-----
From: Andi Kleen [mailto:ak@suse.de]
Sent: Wednesday, April 19, 2006 5:51 PM
To: ravinandan.arakali@neterion.com
Cc: jgarzik@pobox.com; netdev@vger.kernel.org
Subject: Re: [PATCH 2.6.16-rc5] S2io: Receive packet classification and
steering mechanisms


On Thursday 20 April 2006 00:45, Ravinandan Arakali wrote:
> Andi,
> We would like to explain that this patch is tier-1 of a two
> tiered approach. It implements all the steering
> functionality at driver-only level, and it is fairly Neterion-specific.

That's fine for experiments, but probably not something
that should be in tree.

>
> The second upcoming submission will add a generic netlink-based
> interface for channel data flow and configuration(including receive
steering
> parameters) on per-channel basis, that will utilize the lower level
> implementation from the current patch.

Will the driver itself listening to netlink?

My feeling would be to teach the stack to use this would require
efficient interfaces and netlink isn't particularly. But if it's just
a glue module outside the driver that would be reasonable as a first
step I guess.

Do you also plan to release user tools to use it?


-Andi

