From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v2 5/5] wave: Added TCP Wave
Date: Sun, 15 Oct 2017 10:43:29 -0700
Message-ID: <1508089409.31614.74.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171014114714.3694-1-natale.patriciello@gmail.com>
         <20171014114714.3694-6-natale.patriciello@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Ahmed Said <ahmed.said@uniroma2.it>,
        Francesco Zampognaro <zampognaro@ing.uniroma2.it>,
        Cesare Roseti <roseti@ing.uniroma2.it>
To: Natale Patriciello <natale.patriciello@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:49113 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750907AbdJORnb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 13:43:31 -0400
Received: by mail-pg0-f46.google.com with SMTP id v78so5002453pgb.5
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 10:43:31 -0700 (PDT)
In-Reply-To: <20171014114714.3694-6-natale.patriciello@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-10-14 at 13:47 +0200, Natale Patriciello wrote:
> TCP Wave (TCPW) replaces the window-based transmission paradigm of the
> standard TCP with a burst-based transmission, the ACK-clock scheduling
> with a self-managed timer and the RTT-based congestion control loop
> with an Ack-based Capacity and Congestion Estimation (ACCE) module. In
> non-technical words, it sends data down the stack when its internal
> timer expires, and the timing of the received ACKs contribute to
> updating this timer regularly.
> 


> It is the first TCP congestion control that uses the timing constraint
> developed in the Linux kernel.

You seem to have missed BBR.



This is against what we have worked in the last years, preventing bursts
in the first place.

If this series is to address WIFI peculiarities with TSQ (this is a well
known problem, still waiting for a fix), I would rather not add all this
code in TCP and find better alternatives.

Since you do not provide information and testing results, there is no
chance we accept such patches.

Your work seems to be a variation of TSQ, and a very complex one.
