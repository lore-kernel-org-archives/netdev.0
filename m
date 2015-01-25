From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH v3 net-next] net: ipv6: Add sysctl entry to disable MTU
 updates from RA
Date: Sun, 25 Jan 2015 09:21:01 +0200
Message-ID: <20150125072101.GA25495@angus-think.lan>
References: <1421773565-5181-1-git-send-email-harouth@codeaurora.org>
 <20150124.231432.1788575004982971514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: harouth@codeaurora.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:51012 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479AbbAYHbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 02:31:50 -0500
Received: by mail-wg0-f42.google.com with SMTP id x13so4177426wgg.1
        for <netdev@vger.kernel.org>; Sat, 24 Jan 2015 23:31:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150124.231432.1788575004982971514.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 24, 2015 at 11:14:32PM -0800, David Miller wrote:
> From: Harout Hedeshian <harouth@codeaurora.org>
> Date: Tue, 20 Jan 2015 10:06:05 -0700
> 
> > The kernel forcefully applies MTU values received in router
> > advertisements provided the new MTU is less than the current. This
> > behavior is undesirable when the user space is managing the MTU. Instead
> > a sysctl flag 'accept_ra_mtu' is introduced such that the user space
> > can control whether or not RA provided MTU updates should be applied. The
> > default behavior is unchanged; user space must explicitly set this flag
> > to 0 for RA MTUs to be ignored.
> > 
> > Signed-off-by: Harout Hedeshian <harouth@codeaurora.org>
> 
> Under what circumstances would userland ignore a router advertized
> MTU, and are the RFCs ok with this?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hi,

I don't know if it make sense but I had the same use case when was
working on supporting IPv6 infrastructure for home gateway.
One of the provider had requirements to have ability set force IPv6 MTU
value via TR parameters and disable update it via RA.

Regards,
