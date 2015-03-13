From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/2] net: bcmgenet: Byte Queue Limits support
Date: Fri, 13 Mar 2015 16:03:43 -0700
Message-ID: <55036CCF.5020200@gmail.com>
References: <1426287512-10742-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, davem@davemloft.net, jaedon.shin@gmail.com,
	pgynther@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:41708 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982AbbCMXES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 19:04:18 -0400
Received: by pdjy10 with SMTP id y10so32234064pdj.8
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 16:04:17 -0700 (PDT)
In-Reply-To: <1426287512-10742-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/03/15 15:58, Florian Fainelli wrote:
> Hi all,
> 
> This path series adds byte queue limits support to the GENET driver. Just like
> the gianfar driver, we sometimes need to insert a 64 bytes transmit status block
> which is not going to be sent on the wire, just to the TDMA/TBUF, so we need to
> record the correct byte count before doing that SKB inflation.

David, please hold this patch series for now, I found a bunch of small
corner cases with it while bring up/down the interface, will respin later.

Thanks!
-- 
Florian
