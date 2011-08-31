From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 1/2] net: allow to change carrier via sysfs
Date: Wed, 31 Aug 2011 10:26:56 +0200
Message-ID: <20110831082655.GB2010@minipsycho.brq.redhat.com>
References: <1314715608-978-1-git-send-email-jpirko@redhat.com>
 <1314715608-978-2-git-send-email-jpirko@redhat.com>
 <CAHXqBFJh0xjRYv_-2AzwAvpHOUfQ+pD_153qVtNA3Ybo9r3b=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9211 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751550Ab1HaI1B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 04:27:01 -0400
Content-Disposition: inline
In-Reply-To: <CAHXqBFJh0xjRYv_-2AzwAvpHOUfQ+pD_153qVtNA3Ybo9r3b=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Aug 30, 2011 at 08:11:37PM CEST, mirqus@gmail.com wrote:
>2011/8/30 Jiri Pirko <jpirko@redhat.com>:
>> Allow to write to "carrier" attribute. Devices may implement ndo_cha=
nge_carrier
>> callback to allow changing carrier from userspace.
>
>Do you expect drivers using implementation different than just calling
>netif_carrier_on/off? Or is it supposed to also e.g. power down PHYs?

Yes, generally it can be used also for en/disable phy, for testing
purposes if hw and driver would support it.

>
>BTW, I like this feature!
>
>Best Regards,
>Micha=C5=82 Miros=C5=82aw
