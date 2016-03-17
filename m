From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] vlan: propagate gso_max_segs
Date: Thu, 17 Mar 2016 08:26:47 -0700
Message-ID: <1458228407.7353.47.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1458190789.7353.33.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34381 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965634AbcCQP0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 11:26:50 -0400
Received: by mail-pf0-f178.google.com with SMTP id x3so125059757pfb.1
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 08:26:50 -0700 (PDT)
In-Reply-To: <1458190789.7353.33.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-03-16 at 21:59 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> vlan drivers lack proper propagation of gso_max_segs from
> lower device.
> 

BTW, I suspect bridge code needs an update too.

This might be the time to add IFLA_MAX_GSO_SEGS and IFLA_MAX_GSO_SIZE to
help debugging these issues with "ip link show"
