From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH 01/77] atm: convert mpc device to using netdev_ops
Date: Sat, 21 Mar 2009 07:44:37 -0400
Message-ID: <200903211144.n2LBibQE026137@cmf.nrl.navy.mil>
References: <20090321053712.648437543@vyatta.com>
Reply-To: chas3@users.sourceforge.net
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:56274 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753742AbZCULos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 07:44:48 -0400
In-reply-to: <20090321053712.648437543@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this looks fine.  it seems like there should be a better way to handle
this, but it should work.  i dont remember many people using the mpoa
shortcut code though.

In message <20090321053712.648437543@vyatta.com>,Stephen Hemminger writes:
>This converts the mpc device to using new netdevice_ops.
>Compile tested only, needs more than usual review since
>device was swaping pointers around etc.
>
>Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Chas Williams <chas@cmf.nrl.navy.mil>

