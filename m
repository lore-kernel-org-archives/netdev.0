From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Need help debugging memory corruption
Date: Sun, 04 May 2008 16:55:08 +0200
Message-ID: <481DCE4C.9070805@gmail.com>
References: <20080503130951.091392ba@osprey.hogchain.net> <481DC731.5090303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Chris Snook <csnook@redhat.com>
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:53371 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893AbYEDOyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 10:54:55 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1605474fgg.17
        for <netdev@vger.kernel.org>; Sun, 04 May 2008 07:54:54 -0700 (PDT)
In-Reply-To: <481DC731.5090303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 05/04/2008 04:24 PM:
...

> I'm definitely with less experience, so I wonder why it can't be
> a simple race between atl1_clean_rx_ring() and something (maybe even
> pending atl1_intr_rx()) on the other cpu writing skb while kfreeing?


Hmm... atl1_intr_rx() looks impossible, so atl1_alloc_rx_buffers()?

Jarek P. 


