From: Julia Lawall <julia@diku.dk>
Subject: question about drivers/atm/firestream.c
Date: Sat, 15 Aug 2009 19:08:06 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0908151906020.20096@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:51171 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754044AbZHORII (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Aug 2009 13:08:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the file drivers/atm/firestream.c in the function fs_open, there is the 
following code:

       if (vci != ATM_VPI_UNSPEC && vpi != ATM_VCI_UNSPEC)
                set_bit(ATM_VF_ADDR, &atm_vcc->flags);

Should ATM_VPI_UNSPEC and ATM_VCI_UNSPEC be exchanged?  They have the same 
value, but the code looks a bit odd this way nonetheless.

thanks,
julia
