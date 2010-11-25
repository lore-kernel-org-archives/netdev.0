From: Johan Hovold <jhovold@gmail.com>
Subject: Re: [PATCHv2] hso: fix disable_net
Date: Thu, 25 Nov 2010 16:03:04 +0100
Message-ID: <AANLkTikODWoXB1PmB+SFbFWenYm_-o+RJ+czK9LnaXmn@mail.gmail.com>
References: <1290692450.2112.21.camel@filip-linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, pki@ex.com.pl
To: Filip Aben <f.aben@option.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:45566 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490Ab0KYPDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 10:03:07 -0500
In-Reply-To: <1290692450.2112.21.camel@filip-linux>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 25, 2010 at 2:40 PM, Filip Aben <f.aben@option.com> wrote:
> The HSO driver incorrectly creates a serial device instead of a net
> device when disable_net is set. It shouldn't create anything for the
> network interface.
>
> Signed-off-by: Filip Aben <f.aben@option.com>

Please add the appropriate Reported-by-tags as well, e.g.

Reported-by: Piotr Isajew <pki@ex.com.pl>
Reported-by: Johan Hovold <jhovold@gmail.com>

As this patch is meant to fix a driver crash, perhaps it should be marked for
stable as well?

Thanks,
Johan
