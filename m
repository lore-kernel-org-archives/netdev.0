From: Johan Hovold <jhovold@gmail.com>
Subject: Re: [PATCH] hso: fix disable_net
Date: Thu, 25 Nov 2010 13:52:28 +0100
Message-ID: <AANLkTikopSdbg8D1djQn--mh=xvWSauc-CTDY_HM_b6t@mail.gmail.com>
References: <1290627352.1739.19.camel@filip-linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, pki@ex.com.pl, j.dumon@option.com
To: Filip Aben <f.aben@option.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:35261 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103Ab0KYMw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 07:52:29 -0500
In-Reply-To: <1290627352.1739.19.camel@filip-linux>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 24, 2010 at 8:35 PM, Filip Aben <f.aben@option.com> wrote:
> The HSO driver incorrectly creates a serial device instead of a net
> device when disable_net is set. It shouldn't create anything for the
> network interface.

Looks good apart from the indentation issue pointed out by Sergei (you
should also
indent the hso_create_net_device line).

As I mentioned in another thread, this was actually suggested about a year ago
but was never accepted due to patch corruption (the other two patches submitted
as part of that series also seem to have been plain wrong, though):

	http://kerneltrap.org/mailarchive/linux-netdev/2009/11/19/6261572

Thanks,
Johan
