From: David Miller <davem@davemloft.net>
Subject: Re: scp stalls mysteriously
Date: Thu, 03 Dec 2009 13:37:22 -0800 (PST)
Message-ID: <20091203.133722.04752487.davem@davemloft.net>
References: <20091203085933.GD30730@sd-11162.dedibox.fr>
	<alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi>
	<20091203183207.GA13626@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, fredo@starox.org,
	damian@tvk.rwth-aachen.de, netdev@vger.kernel.org,
	asdo@shiftmail.org, eric.dumazet@gmail.com,
	herbert@gondor.apana.org.au
To: gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34419
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753815AbZLCVhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 16:37:16 -0500
In-Reply-To: <20091203183207.GA13626@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg KH <gregkh@suse.de>
Date: Thu, 3 Dec 2009 10:32:07 -0800

> On Thu, Dec 03, 2009 at 12:29:39PM +0200, Ilpo Järvinen wrote:
>> I've added Greg as CC to make him aware of this issue in early as it now 
>> affects 2.6.32 too (rather important to get dealt quickly in stable once 
>> we have a tested solution since TCP is pretty broken with the silent 
>> deaths this problem seems to cause). ...One possibility would be to just 
>> queue the tested revert to stable and sort this thing out for 2.6.33 in 
>> net-2.6.
>> 
>> Opinions, Dave?, Greg?
> 
> As always, if you have a patch that you want in the -stable tree, send
> it, with the git commit id of the patch that is in Linus's tree, to the
> stable@kernel.org email address so I don't loose it.

Yep, we'll do that once we track this down and make a final decision
on how to fix it.
