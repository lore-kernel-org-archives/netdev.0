From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] htb: add support for direct_qlen attribute
Date: Fri, 13 Sep 2013 08:33:47 -0700
Message-ID: <1379086427.24408.42.camel@edumazet-glaptop>
References: <1379086235.24408.41.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:64528 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753352Ab3IMPdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 11:33:50 -0400
Received: by mail-pd0-f173.google.com with SMTP id p10so1392583pdj.18
        for <netdev@vger.kernel.org>; Fri, 13 Sep 2013 08:33:50 -0700 (PDT)
In-Reply-To: <1379086235.24408.41.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-09-13 at 08:30 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> TCA_HTB_DIRECT_QLEN attribute is supported since linux-3.10
> 
> HTB classes use an internal pfifo queue, which limit was not reported

s/classes/qdisc/

> by tc, and value inherited from device tx_queue_len at setup time.
>     
> With this patch, tc displays the value and can change it.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
