From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] packet: make packet too small warning match
 condition
Date: Mon, 12 Jan 2015 16:01:42 -0500 (EST)
Message-ID: <20150112.160142.1336336585363442369.davem@davemloft.net>
References: <1420734558-30979-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jkmalinen@gmail.com, dborkman@redhat.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53762 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbbALVBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 16:01:46 -0500
In-Reply-To: <1420734558-30979-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Thu,  8 Jan 2015 11:29:18 -0500

> From: Willem de Bruijn <willemb@google.com>
> 
> The expression in ll_header_truncated() tests less than or equal, but
> the warning prints less than. Update the warning.
> 
> Reported-by: Jouni Malinen <jkmalinen@gmail.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Yeah that could be really confusing.  Applied, thanks.
