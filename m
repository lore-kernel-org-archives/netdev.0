From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH] usb: usbnet: suspend count gets lost when -EBUSY
Date: Thu, 7 Jul 2011 13:50:36 -0700
Message-ID: <20110707205036.GB13006@kroah.com>
References: <CADuEq9BQX2BFBY3pF=CEEymfK4JPwMP7By+JZFdaLqxs+GhtJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	stable@kernel.org
To: C.Fries@motorola.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5.smtp.messagingengine.com ([66.111.4.29]:33244 "EHLO
	out5.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750958Ab1GGUv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 16:51:59 -0400
Content-Disposition: inline
In-Reply-To: <CADuEq9BQX2BFBY3pF=CEEymfK4JPwMP7By+JZFdaLqxs+GhtJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 05, 2011 at 08:35:05PM -0500, Chris Fries wrote:
> When suspend is refused due to pending transmits, the
> busy counter gets out of sync, and suspend will stop
> working correctly.
> 
> Signed-off-by: Chris Fries <C.Fries@motorola.com>
> ---
>  drivers/net/usb/usbnet.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>
