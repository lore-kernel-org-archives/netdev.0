From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 2.6.16-rc5] S2io: Receive packet classification and steering mechanisms
Date: Thu, 20 Apr 2006 02:51:14 +0200
Message-ID: <200604200251.14309.ak@suse.de>
References: <MAEEKMLDLDFEGKHNIJHIEEJDCDAA.ravinandan.arakali@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:12444 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1750704AbWDTAvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2006 20:51:20 -0400
To: ravinandan.arakali@neterion.com
In-Reply-To: <MAEEKMLDLDFEGKHNIJHIEEJDCDAA.ravinandan.arakali@neterion.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 20 April 2006 00:45, Ravinandan Arakali wrote:
> Andi,
> We would like to explain that this patch is tier-1 of a two
> tiered approach. It implements all the steering
> functionality at driver-only level, and it is fairly Neterion-specific.

That's fine for experiments, but probably not something
that should be in tree.

> 
> The second upcoming submission will add a generic netlink-based
> interface for channel data flow and configuration(including receive steering
> parameters) on per-channel basis, that will utilize the lower level
> implementation from the current patch.

Will the driver itself listening to netlink? 

My feeling would be to teach the stack to use this would require
efficient interfaces and netlink isn't particularly. But if it's just
a glue module outside the driver that would be reasonable as a first
step I guess.

Do you also plan to release user tools to use it?


-Andi
