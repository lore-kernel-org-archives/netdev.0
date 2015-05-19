From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inet: properly align icsk_ca_priv
Date: Tue, 19 May 2015 00:29:41 -0400 (EDT)
Message-ID: <20150519.002941.784968835418101908.davem@davemloft.net>
References: <1431894670-12609-1-git-send-email-kennetkl@ifi.uio.no>
	<20150518151648.6d33128c@urahara>
	<1431993974.621.50.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, fan.du@intel.com, kennetkl@ifi.uio.no,
	netdev@vger.kernel.org, davihay@ifi.uio.no, ycheng@google.com,
	apetlund@simula.no
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35055 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbbESE3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 00:29:43 -0400
In-Reply-To: <1431993974.621.50.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 18 May 2015 17:06:14 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> tcp_illinois and upcoming tcp_cdg require 64bit alignment of
> icsk_ca_priv
> 
> x86 does not care, but other architectures might.
> 
> Fixes: 05cbc0db03e82 ("ipv4: Create probe timer for tcp PMTU as per RFC4821")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
