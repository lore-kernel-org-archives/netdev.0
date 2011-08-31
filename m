From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch net-next-2.6 1/2] net: allow to change carrier via sysfs
Date: Wed, 31 Aug 2011 10:33:50 +0200
Message-ID: <CAHXqBFJpSZNhkur7QNYbjG-=Bkq2HtHKEHsn+H3TnEJ5NezJoA@mail.gmail.com>
References: <1314715608-978-1-git-send-email-jpirko@redhat.com>
 <1314715608-978-2-git-send-email-jpirko@redhat.com> <CAHXqBFJh0xjRYv_-2AzwAvpHOUfQ+pD_153qVtNA3Ybo9r3b=w@mail.gmail.com>
 <20110831082655.GB2010@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:41346 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753263Ab1HaIeL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 04:34:11 -0400
Received: by iabu26 with SMTP id u26so535673iab.19
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2011 01:34:11 -0700 (PDT)
In-Reply-To: <20110831082655.GB2010@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 31 sierpnia 2011 10:26 u=BFytkownik Jiri Pirko <jpirko@redhat.co=
m> napisa=B3:
> Tue, Aug 30, 2011 at 08:11:37PM CEST, mirqus@gmail.com wrote:
>>2011/8/30 Jiri Pirko <jpirko@redhat.com>:
>>> Allow to write to "carrier" attribute. Devices may implement ndo_ch=
ange_carrier
>>> callback to allow changing carrier from userspace.
>>Do you expect drivers using implementation different than just callin=
g
>>netif_carrier_on/off? Or is it supposed to also e.g. power down PHYs?
> Yes, generally it can be used also for en/disable phy, for testing
> purposes if hw and driver would support it.

I'd like to see this working for GRE tunnel devices (for keepalive
daemon to be able to indicate to routing daemons whether tunnel is
really working) - implementation would be identical to dummy's case.
Should I prepare a patch or can I leave it to you?

Best Regards,
Micha=B3 Miros=B3aw
