From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 12/13] s390/qeth: support GRO flush timer
Date: Wed, 18 Oct 2017 09:08:30 -0700
Message-ID: <1508342910.31614.121.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
         <20171018154025.73630-13-jwi@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-s390@vger.kernel.org,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>
To: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:46033 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750910AbdJRQIc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 12:08:32 -0400
In-Reply-To: <20171018154025.73630-13-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-10-18 at 17:40 +0200, Julian Wiedmann wrote:
> Switch to napi_complete_done(), and thus enable delayed GRO flushing.
> The timeout is configured via /sys/class/net/<if>/gro_flush_timeout.
> 
> Default timeout is 0, so no change in behaviour.
> 
> Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
> ---

Reviewed-by: Eric Dumazet <edumazet@google.com>
