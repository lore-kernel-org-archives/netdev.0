From: Rodolfo Giometti <giometti@enneenne.com>
Subject: Re: Generic netlink interface help
Date: Mon, 28 May 2007 09:41:20 +0200
Message-ID: <20070528074120.GC20506@gundam.enneenne.com>
References: <20070524085956.GP7089@enneenne.com> <84po8XY4.1179999810.5490870.samuel@sortiz.org> <20070527173959.GU21180@enneenne.com> <20070528014247.GC4264@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-174-11-161.f5.ngi.it ([81.174.11.161]:53824 "EHLO
	mail.enneenne.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752091AbXE1Hl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2007 03:41:28 -0400
Content-Disposition: inline
In-Reply-To: <20070528014247.GC4264@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 28, 2007 at 04:42:47AM +0300, Samuel Ortiz wrote:
> > 
> > Is that right?
> At first glance, this could work yes.

Great! Now I have only to write the userland tool. :)

> However, it seems you're trying to encapsulate your pps_netlink_msg into
> a generic netlink message which itself is already encapsulated into a
> netlink message, and then multiplex all your PPS commands on
> ppl_genl_data_ready(). IMHO, you should have your different PPS commands
> declared as a genl_ops array, and then have a specific doit routine per PPS
> command. This would make your code cleaner and more secure (see the
> "Operation Granularity" section at
> http://linux-net.osdl.org/index.php/Generic_Netlink_HOWTO).

I see. I already supposed that but currently I'm trying to do minimal
changes to my code in order to verify that everythink works well
again, then I'll do the complete work.

Thanks a lot,

Rodolfo

-- 

GNU/Linux Solutions                  e-mail:    giometti@enneenne.com
Linux Device Driver                             giometti@gnudd.com
Embedded Systems                     		giometti@linux.it
UNIX programming                     phone:     +39 349 2432127
