From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: unix: Align send data_len up to PAGE_SIZE
Date: Thu, 15 May 2014 06:27:20 -0700
Message-ID: <1400160440.7973.135.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399906332.31472.1.camel@tkhai>
	 <20140514.151504.1740922429122469259.davem@davemloft.net>
	 <1400144080.3782.23.camel@tkhai>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	edumazet@google.com
To: Kirill Tkhai <ktkhai@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:65075 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753954AbaEON1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 09:27:23 -0400
Received: by mail-pb0-f45.google.com with SMTP id um1so1106203pbc.32
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 06:27:22 -0700 (PDT)
In-Reply-To: <1400144080.3782.23.camel@tkhai>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-05-15 at 12:54 +0400, Kirill Tkhai wrote:

> 
> And I assumed it's OK to allocate skbs with zero header size like this:
> 
> sock_alloc_send_pskb(sk, 0, data_len)
> 
> Please say, if it's wrong.
> 

Its OK
