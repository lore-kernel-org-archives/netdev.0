From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] ethernet: use likely() for common
 Ethernet encap
Date: Mon, 30 Sep 2013 21:53:51 -0700 (PDT)
Message-ID: <20130930.215351.661834242294300223.davem@davemloft.net>
References: <20130927171941.0dad4d2a@nehalam.linuxnetplumber.net>
	<20130927172127.566a1a1d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42383 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024Ab3JAEqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 00:46:45 -0400
In-Reply-To: <20130927172127.566a1a1d@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 27 Sep 2013 17:21:27 -0700

> Mark code path's likely/unlikely based on most common usage.
>   * Very few devices use dsa tags.
>   * Most traffic is Ethernet (not 802.2)
>   * No sane person uses trailer type or Novell encapsulation
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
