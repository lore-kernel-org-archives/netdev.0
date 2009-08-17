From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: question about drivers/atm/firestream.c
Date: Mon, 17 Aug 2009 10:25:51 -0400
Message-ID: <200908171425.n7HEPpjw009747@cmf.nrl.navy.mil>
References: <Pine.LNX.4.64.0908151906020.20096@ask.diku.dk>
Reply-To: chas3@users.sourceforge.net
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:39799 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755131AbZHQOej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 10:34:39 -0400
Reply-To: chas3@users.sourceforge.net
In-reply-to: <Pine.LNX.4.64.0908151906020.20096@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <Pine.LNX.4.64.0908151906020.20096@ask.diku.dk>,Julia Lawall writes:
>In the file drivers/atm/firestream.c in the function fs_open, there is the 
>following code:
>
>       if (vci != ATM_VPI_UNSPEC && vpi != ATM_VCI_UNSPEC)
>                set_bit(ATM_VF_ADDR, &atm_vcc->flags);
>
>Should ATM_VPI_UNSPEC and ATM_VCI_UNSPEC be exchanged?  They have the same 
>value, but the code looks a bit odd this way nonetheless.

yes this is backwards.  this whole UNSPEC business should really go away.
drivers should never need to worry about getting an unspecified vpi or
vci.  this should be chosen by the next layer up in the stack.
