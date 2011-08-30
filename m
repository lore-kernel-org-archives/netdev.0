From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch net-next-2.6 1/2] net: allow to change carrier via sysfs
Date: Tue, 30 Aug 2011 20:11:37 +0200
Message-ID: <CAHXqBFJh0xjRYv_-2AzwAvpHOUfQ+pD_153qVtNA3Ybo9r3b=w@mail.gmail.com>
References: <1314715608-978-1-git-send-email-jpirko@redhat.com> <1314715608-978-2-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:35491 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752643Ab1H3SL6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 14:11:58 -0400
Received: by gwaa12 with SMTP id a12so5812383gwa.19
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 11:11:57 -0700 (PDT)
In-Reply-To: <1314715608-978-2-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/8/30 Jiri Pirko <jpirko@redhat.com>:
> Allow to write to "carrier" attribute. Devices may implement ndo_chan=
ge_carrier
> callback to allow changing carrier from userspace.

Do you expect drivers using implementation different than just calling
netif_carrier_on/off? Or is it supposed to also e.g. power down PHYs?

BTW, I like this feature!

Best Regards,
Micha=C5=82 Miros=C5=82aw
