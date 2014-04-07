From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 6/6] net: Implmement RFC 6936 (zero RX csums
 for UDP/IPv6)
Date: Mon, 07 Apr 2014 10:25:44 -0700
Message-ID: <1396891544.12330.65.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1404041720560.21339@tomh.mtv.corp.google.com>
	 <20140407.131633.1635128478858805272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:53902 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718AbaDGRZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 13:25:46 -0400
Received: by mail-pa0-f53.google.com with SMTP id ld10so7026952pab.40
        for <netdev@vger.kernel.org>; Mon, 07 Apr 2014 10:25:45 -0700 (PDT)
In-Reply-To: <20140407.131633.1635128478858805272.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-04-07 at 13:16 -0400, David Miller wrote:

> The safest thing to do is to create the new option, then there
> is no discrepancy.


Btw SO_NO_CHECK is a SOL_SOCKET option.
