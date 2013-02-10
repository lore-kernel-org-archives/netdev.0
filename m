From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: [net-next (TAKE 2) 0/4] IPv6 over Firewire
Date: Sun, 10 Feb 2013 13:48:20 +0100
Message-ID: <51179714.6010706@gmail.com>
References: <5117620A.4050005@linux-ipv6.org> <51177689.4070904@gmail.com> <51177B15.3030405@linux-ipv6.org>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	davem@davemloft.net, stefanr@s5r6.in-berlin.de
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:62286 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754398Ab3BJMsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 07:48:24 -0500
Received: by mail-ee0-f46.google.com with SMTP id e49so2724249eek.5
        for <netdev@vger.kernel.org>; Sun, 10 Feb 2013 04:48:23 -0800 (PST)
In-Reply-To: <51177B15.3030405@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> I have tested against MacOS X 10.5.8.
> 
> ARP and ping works but unfortunately NDP does not seem to work.
> 
> If I assign static NDP entry on Linux, ping6 ff02::1%fw0 from MacOS
> works well.
> 
> I checked tcpdump on both side, and I guess this is because MacOS is
> broken; - tcpdump on Linux side complains that ICMP checksum is
> incorrect. - tcpdump on MacOS side says that length of Link-layer
> address option is 2 (16) instead of 3 (24).

Than I would assume that there is a bug in your new implementation.
RFC3146 section 8 states that the link layer option is of length 3. In
addition, my proof of concept implementation also worked with MacOS X
and I double checked the ndisc packets directly on the firewire line
using a firewire sniffing device (firespy).

Regards,

Stephan
