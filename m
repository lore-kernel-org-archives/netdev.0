From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next] vlan: Pass ethtool get_ts_info queries to real
 device.
Date: Mon, 24 Nov 2014 08:38:45 +0100
Message-ID: <20141124073845.GA4183@localhost.localdomain>
References: <1416575780-19132-1-git-send-email-richardcochran@gmail.com>
 <1416712512.7215.34.camel@decadent.org.uk>
 <20141123160533.GA4562@netboy>
 <20141123.134809.1311687203339230014.davem@davemloft.net>
 <1416769497.7215.56.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	stefan.sorensen@spectralink.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:53265 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752327AbaKXHiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 02:38:50 -0500
Received: by mail-wg0-f43.google.com with SMTP id l18so11785463wgh.16
        for <netdev@vger.kernel.org>; Sun, 23 Nov 2014 23:38:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1416769497.7215.56.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 23, 2014 at 07:04:57PM +0000, Ben Hutchings wrote:
> The two datasheets I've looked at so far (EG20T for pch_gbe driver,
> BF518 for bfin_mac driver) mention support for 802.1q but not 802.1ad.
> I already mentioned ptp_classify.c doesn't support 802.1ad, and I can't
> see how it would ever make sense to run PTP directly over 802.1ad
> anyway.

Me, neither.
 
> I'll read some more datasheets to see whether 802.1q is generally
> supported, but for 802.1ad VLAN devices I think we should pass-through
> only the NONE and ALL filter capabilities.

Fine with me.

Thanks,
Richard
