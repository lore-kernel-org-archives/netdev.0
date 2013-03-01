From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: [net-next (TAKE 2) 0/4] IPv6 over Firewire
Date: Fri, 01 Mar 2013 11:28:21 +0100
Message-ID: <513082C5.804@gmail.com>
References: <5117620A.4050005@linux-ipv6.org> <51177689.4070904@gmail.com> <51177B15.3030405@linux-ipv6.org> <51179714.6010706@gmail.com> <5117B73C.10600@linux-ipv6.org> <5118C8B3.7080803@gmail.com> <5118EE78.5000508@linux-ipv6.org> <511A9BFC.9010907@gmail.com>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	davem@davemloft.net, stefanr@s5r6.in-berlin.de
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:60809 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979Ab3CAK2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Mar 2013 05:28:25 -0500
Received: by mail-ee0-f45.google.com with SMTP id b57so2300996eek.32
        for <netdev@vger.kernel.org>; Fri, 01 Mar 2013 02:28:23 -0800 (PST)
In-Reply-To: <511A9BFC.9010907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Yoshfuji,

> Nevertheless, there is some hope that I can try out your patch set
> during this week and find some insight why IPv6 does not work with MacOS X.

Unfortunately, until now I did not find some time to try out your IPv6 
over firewire implementation. But now I did.

I just fired a ping6 from my Linux box running your kernel.

Using a FireSpy device I sniffed directly on the firewire line and 
dumped the ndisc packets. They look pretty well, I can't see any 
problems. The only thing I can't really judge about is the ICMPv6 
checksum. But wireshark says the checksum is correct.

Hopefully I get a MacOS X notebook today so that I can also sniff the 
packets from MacOS too.

I'll keep you informed.

Regards,

Stephan
