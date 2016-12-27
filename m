From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: driver r8169 suddenly failed
Date: Wed, 28 Dec 2016 00:12:42 +0100
Message-ID: <20161227231242.GA4638@electric-eye.fr.zoreil.com>
References: <428aa40c-e313-99ae-d3ae-97b6a5ef40e4@modulonet.fr>
 <20161227001248.GA20172@electric-eye.fr.zoreil.com>
 <fd0ba97f-8730-4f71-9bd4-7a7552f673d2@modulonet.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
        netdev@vger.kernel.org
To: Robert Grasso <robert.grasso@modulonet.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50356 "EHLO
        violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753332AbcL0XXq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 18:23:46 -0500
Content-Disposition: inline
In-Reply-To: <fd0ba97f-8730-4f71-9bd4-7a7552f673d2@modulonet.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Grasso <robert.grasso@modulonet.fr> :
[...]
> So, what is your opinion :
> - should I broaden my request for help to other teams than yours (kernel
> maintainers) ?

If I had to untangle this mess, I would check that my router is not
configured with an empty dhcp range. Then I would put each and every
interface facing it in promiscuous (tcpdump) capture mode until one
of those is able to negotiate a dhcp lease. I would thereafter replace
it with the r8169 interface and compare the traffic (+ ethtool byte/packet
counters).

-- 
Ueimor
