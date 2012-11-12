From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] cdc_ether: use USB_DEVICE_AND_INTERFACE_INFO for
 Novatel 551L/E362
Date: Mon, 12 Nov 2012 11:14:19 -0600
Message-ID: <1352740459.2314.7.camel@dcbw.foobar.com>
References: <1352398152.22225.14.camel@dcbw.foobar.com>
	 <20121109.160725.1803281494550920517.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, aleksander@gnu.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43000 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752778Ab2KLRON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2012 12:14:13 -0500
In-Reply-To: <20121109.160725.1803281494550920517.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-09 at 16:07 -0500, David Miller wrote:
> From: Dan Williams <dcbw@redhat.com>
> Date: Thu, 08 Nov 2012 12:09:12 -0600
> 
> > Small cleanup.
> > 
> > Signed-off-by: Dan Williams <dcbw@redhat.com>
> > Cc: stable@vger.kernel.org
> 
> Don't do things like this, _please_.
> 
> A cleanup is absolutely not appropriate for -stable.   Yet you
> tagged this as being destined for there.

Ok.

> What's more this screws up the second patch, which in fact could
> be -stable material.  But I'm not going to apply it as it is
> because it could have dependencies on this patch which as
> states is not inappropriate for both 'net' and -stable.

I did carefully check that the context for the second patch
(qmi_wwan/cdc_ether: add Dell Wireless 5800 (Novatel E362) USB IDs) was
*not* dependent on the first patch.  Hence I did not post them as a
series, but as separate patches, as they should be independently
applicable.

> I'm therefore tossing both of these changes, submit things properly
> please.

I will resubmit both patches, with "qmi_wwan/cdc_ether: add Dell
Wireless 5800 (Novatel E362) USB IDs" cc-ed to stable@, but this patch
(cdc_ether: use USB_DEVICE_AND_INTERFACE_INFO for Novatel 551L/E362)
only for net-next.

Thanks,
Dan
