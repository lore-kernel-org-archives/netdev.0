From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next] r8169: Support for byte queue limits
Date: Sat, 3 Dec 2011 01:20:40 +0100
Message-ID: <20111203002040.GA15709@electric-eye.fr.zoreil.com>
References: <igorm@etf.rs> <1322831399-23505-1-git-send-email-igorm@etf.rs> <1322836191.2762.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: igorm@etf.rs, netdev@vger.kernel.org, davem@davemloft.net,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38633 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416Ab1LCA1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 19:27:22 -0500
Content-Disposition: inline
In-Reply-To: <1322836191.2762.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> :
[...]
> Also please CC maintainers of this driver to your submission.
> 
> (I did this)

Thanks.

Frankly I would appreciate if people could wait a bit until fixes for
the current RxFIFOOverflow mess - and a bit more - are submitted. I just
need the week end for some sanity tested patches with a few different
nic.

Btw some code may be saved with an adequate ad-hoc {bytes/tx}_compl
struct and a few helpers acting on it as well as dev/dev->stats and
skb.

--
Ueimor
