From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 2/2] cpsw: fix leaking IO mappings
Date: Sun, 4 Nov 2012 16:16:20 +0100
Message-ID: <20121104151620.GA2175@netboy.at.omicron.at>
References: <cover.1351930782.git.richardcochran@gmail.com>
 <1c915a7d0301355342358db8f84560417609a61c.1351930782.git.richardcochran@gmail.com>
 <50966C6E.1000507@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	David Miller <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Vaibhav Hiremath <hvaibhav@ti.com>
To: Cyril Chemparathy <cyril@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:38794 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752671Ab2KDPQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Nov 2012 10:16:32 -0500
Received: by mail-ea0-f174.google.com with SMTP id c13so1947634eaa.19
        for <netdev@vger.kernel.org>; Sun, 04 Nov 2012 07:16:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <50966C6E.1000507@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 04, 2012 at 02:23:58PM +0100, Cyril Chemparathy wrote:
> On 11/03/2012 09:25 AM, Richard Cochran wrote:
> >The CPSW driver remaps two different IO regions, but fails to unmap them
> >both. This patch fixes the issue by calling iounmap in the appropriate
> >places.
> 
> Any thoughts on using devres helpers to keep the bail out path simpler?

I wasn't aware of devres before, but I just read through the doc. It
looks interesting, and if I were writting a new driver, then I might
use it.

But for this driver, it really isn't very complex. It only looks that
way, but I think this just accidental. I guess that the code was
adapted from the davinci emac driver.

Thanks,
Richard
