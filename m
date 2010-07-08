From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Pull request: bluetooth-2.6 2010-07-08
Date: Thu, 08 Jul 2010 20:28:54 -0300
Message-ID: <1278631734.10421.88.camel@localhost.localdomain>
References: <cover.1278619047.git.marcel@holtmann.org>
	 <20100708.154637.71104736.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:39105 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758742Ab0GHX3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 19:29:10 -0400
In-Reply-To: <20100708.154637.71104736.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> > these patches fix a few bugs and crashes and also two security related
> > issues with the authentication procedure.
> 
> 13 changes is too much this late in the -RC series.  Fixes need to
> trickle in, in small quantities, and therefore it's critical that
> maintainers submit fixes often and as soon as they are ready.
> 
> Please pick a small number of the most critical fixes, say 3 or 4.  An
> easy way to roughly quantify which ones shoule be included is:
> 
> 1) Is there an OOPS or crash regression reported by real users and
>    listed in the official lkml regression list which is caused by this
>    problem?
> 
> 2) Is there an exploitable security concern fixed by this change?
> 
> Else, it's only net-next-2.6 material.
> 
> For example:
> 
>     Bluetooth: Remove max_tx and tx_window module paramenters from L2CAP
> 
> Things like that change are absolutely not appropriate at this
> stage in the post merge-window development environment.

I can take these out and leave them for -next. That is fine with me, but
you asked Gustavo to remove these. And so I left them in.

Regards

Marcel


