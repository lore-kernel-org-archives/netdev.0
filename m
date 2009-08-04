From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v1] tun: Cleanup error handling in tun_set_iff()
Date: Mon, 03 Aug 2009 21:16:39 -0700 (PDT)
Message-ID: <20090803.211639.93476997.davem@davemloft.net>
References: <20090803161242.12947.14620.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37605
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751903AbZHDEQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 00:16:30 -0400
In-Reply-To: <20090803161242.12947.14620.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Mon, 03 Aug 2009 12:12:43 -0400

> Convert some pointless gotos into returns and ensure tun_attach() errors are
> handled correctly.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>
> 
> --
> 
> I'm sending this as an RFC patch because I'm not entirely certain that the
> changes to the tun_attach() error handling code are 100% correct, although I
> strongly suspect that the current behavor of simply returning an error code
> without any cleanup is broken.  Can anyone comment on this?

It looks good to me.

But I've been wrong about this code before, so it would be nice
to get some other eyes on it :-)
