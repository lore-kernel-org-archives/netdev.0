From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pptp: fix byte order warnings
Date: Tue, 13 Aug 2013 15:11:15 -0700 (PDT)
Message-ID: <20130813.151115.147152336246462450.davem@davemloft.net>
References: <20130810152258.1cef6d89@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xeb@mail.ru, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44737 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758830Ab3HMWLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 18:11:16 -0400
In-Reply-To: <20130810152258.1cef6d89@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sat, 10 Aug 2013 15:22:58 -0700

> Pptp driver has lots of byte order warnings from sparse.
> This was because the on-the-wire header is in network byte order (obviously)
> but the definition did not reflect that.
> 
> Also, the address structure to user space actually put the call id
> in host order. Rather than break ABI compatibility, just acknowledge
> the existing design.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, thanks.
