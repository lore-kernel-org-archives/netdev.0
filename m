From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/4] pch_gbe: Fix transmit queue management
Date: Mon, 02 Dec 2013 08:51:55 -0800
Message-ID: <1386003115.5352.59.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1385631882-12827-2-git-send-email-puzman@gmail.com>
	 <20131129.164229.2292905485668904870.davem@davemloft.net>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B744F@saturn3.aculab.com>
	 <20131202.111600.1622488165507147936.davem@davemloft.net>
	 <1386001999.5352.51.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, puzman@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:47387 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752957Ab3LBQwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 11:52:00 -0500
In-Reply-To: <1386001999.5352.51.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-02 at 08:33 -0800, Eric Dumazet wrote:

> So far, only virtual drivers and 2 or 3 others advertise
> NETIF_F_FRAGLIST 'support'.
> 
> I suspect that the '2 or 3 others' are plain bugs, I'll check this.
> 

Yep, these all are plain bugs, I submitted a fix.
