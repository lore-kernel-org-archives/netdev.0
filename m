From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: sched: use no more than one page in
 struct fw_head
Date: Mon, 17 Mar 2014 20:02:41 -0700
Message-ID: <1395111761.9114.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140314185917.GA18933@linux.vnet.ibm.com>
	 <1394826958.9668.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1394985990.9668.26.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140317.223151.719003141867577870.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, netdev@vger.kernel.org, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:57402 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753112AbaCRDCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 23:02:43 -0400
Received: by mail-pa0-f54.google.com with SMTP id lf10so6665086pab.27
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 20:02:43 -0700 (PDT)
In-Reply-To: <20140317.223151.719003141867577870.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-17 at 22:31 -0400, David Miller wrote:

> Eric let's just use an HSIZE of 256 and be done with it.
> 
> Then all of this talk of divides and cost goes out the window, as we
> can assume a power of two and use simple masking.
> 
> This is basically what other classifiers in similar situations do.

Yep, will send a v2.
