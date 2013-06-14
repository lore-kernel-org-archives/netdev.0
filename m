From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [RFC PATCH net-next] mlx4_en: Do not set dev_id to port number
Date: Fri, 14 Jun 2013 23:18:27 +0300
Message-ID: <CAJZOPZK2XZSU7GB6TBV83FXHvTX26kAB+D6yPH+54YZPp_Te_g@mail.gmail.com>
References: <20130614150624.GA1316@fedora-17-guest.blr.amer.dell.com>
	<CAJZOPZLv9aidr7fV_2ntqy1DeZZGd9yUHZT1Dqbk=w-bssw69Q@mail.gmail.com>
	<1371240882.1940.18.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Narendra_K@dell.com, netdev@vger.kernel.org, ogerlitz@mellanox.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:34748 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753802Ab3FNUS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 16:18:28 -0400
Received: by mail-qc0-f178.google.com with SMTP id c11so546920qcv.37
        for <netdev@vger.kernel.org>; Fri, 14 Jun 2013 13:18:27 -0700 (PDT)
In-Reply-To: <1371240882.1940.18.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 14, 2013 at 11:14 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:

> If you have userland tools relying on this then I agree it should be
> left alone, but maybe add a comment explaining why the field is used in
> an unusual way.

we were not aware that it used in unsual way, just used that b/c were told
too, not sure what to put in the comment. As for userland tools, I know
about internal regression tools and some clould related scripts that use
that.
