From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ax88179_178a: avoid copy of tx tcp packets
Date: Sat, 03 Aug 2013 21:56:14 -0700 (PDT)
Message-ID: <20130803.215614.1931944930674167595.davem@davemloft.net>
References: <1375363300.10515.135.camel@edumazet-glaptop>
	<1375364992.10515.141.camel@edumazet-glaptop>
	<1375365165.10515.143.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ming.lei@canonical.com, gregkh@linuxfoundation.org,
	oneukum@suse.de, freddy@asix.com.tw, bhutchings@solarflare.com,
	grundler@google.com, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56361 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124Ab3HDE4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Aug 2013 00:56:16 -0400
In-Reply-To: <1375365165.10515.143.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 01 Aug 2013 06:52:45 -0700

> On Thu, 2013-08-01 at 06:49 -0700, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> ax88179_tx_fixup() has quite complex code trying to push 8 bytes
>> of control data (len/mss), but fails to do it properly for TCP packets,
>> incurring an extra copy and point of memory allocation failure.
> 
> I forgot to say this patch is for net-next, but depends on following fix
> from net tree being applied.
> 
> commit 20f0170377264e8449b6987041f0bcc4d746d3ed
> ("usbnet: do not pretend to support SG/TSO")

Thanks for letting me know.

Applied, thanks Eric.
