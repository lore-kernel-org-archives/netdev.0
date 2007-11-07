From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH][PACKET] Remove unneeded packet_socks_nr variable
Date: Wed, 07 Nov 2007 19:16:14 +0300
Message-ID: <4731E4CE.6030603@openvz.org>
References: <4731DAA3.7060306@openvz.org> <20071107155004.GI27345@ghostprotocols.net> <20071107155301.GJ27345@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:50310 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753379AbXKGQQ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 11:16:28 -0500
In-Reply-To: <20071107155301.GJ27345@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo wrote:
> Em Wed, Nov 07, 2007 at 01:50:04PM -0200, Arnaldo Carvalho de Melo escreveu:
>> Em Wed, Nov 07, 2007 at 06:32:51PM +0300, Pavel Emelyanov escreveu:
>>> This one is used only under ifdef PACKET_REFCNT_DEBUG in
>>> printk and is not needed otherwise. So hide all this stuff
>>> under the PACKET_REFCNT_DEBUG.
>>>
>>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>> Look at sk_refcnt_debug_inc, etc and you'll se a more standard way. I
>> forgot to make this when making all protocol families use sk_prot, even
>> if just partially :-)
> 
> As a bonus you'll get this information on /proc/net/protocols, removing
> '-1' from PACKET column for "sockets".

Hm... I actually thought about this, but I decided that packet
sockets were not accounted in this way deliberately.

So, shall I break this "compatibility" (-1 in proc) and provide
a packet socket number in this file?

> - Arnaldo

Thanks,
Pavel
