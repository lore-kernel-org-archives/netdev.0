From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: CONFIG_ARPD help text
Date: Thu, 11 Jun 2009 21:28:21 +0300
Message-ID: <4A314CC5.9090505@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:46677 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbZFKS2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 14:28:18 -0400
Received: by ewy6 with SMTP id 6so2262472ewy.37
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 11:28:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I just re-read again the CONFIG_ARPD help text. It says it's
"experimental and also obsolete".

But as opennhrp relies on this, and has shown the usefulness for
this interface - it can be used to implement other protocols that
resolve neighbor address than ARP in userland. In this case the
NHRP protocol.

Would it be acceptable to remove the designation as "obsolete"?

Also, I'm running the opennhrp on production with reasonable
size network (100+ nodes in gre subnet). And with the fix I sent
previously it seems to work very stable. Is there something more
to be done, or could the "experimental" marking be removed also?

I could also update the help to explain where the option is useful.
Or should the option be renamed to something like NEIGH_NETLINK?
It also seems that IPv6 supports CONFIG_ARPD so it should probably
be moved from net/ipv4/Kconfig to likely net/core/Kconfig?

Thanks,
  Timo
