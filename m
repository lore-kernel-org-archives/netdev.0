From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 2/2] net: bcmgenet: add support for xmit_more
Date: Fri, 13 Mar 2015 12:49:07 -0700
Message-ID: <1426276147.11398.191.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426273867-10874-1-git-send-email-f.fainelli@gmail.com>
	 <1426273867-10874-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, davem@davemloft.net,
	jaedon.shin@gmail.com, pgynther@google.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:36264 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030257AbbCMTyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 15:54:55 -0400
Received: by iegc3 with SMTP id c3so126661427ieg.3
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 12:54:49 -0700 (PDT)
In-Reply-To: <1426273867-10874-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-03-13 at 12:11 -0700, Florian Fainelli wrote:
> Delay the update of the TDMA producer index unless this is the last SKB
> in a batch, or the queue is already stopped. Move the check for whether
> the queue should be stopped before the xmit_more check to avoid locking
> the transmit queue in case there was a SKB submitted which has xmit_more
> set.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Acked-by: Eric Dumazet <edumazet@google.com>
