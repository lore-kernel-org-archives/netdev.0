From: "Gustavo F. Padovan" <padovan@profusion.mobi>
Subject: Re: [PATCH] bluetooth: Fix failure to release lock in
 read_index_list() when mem alloc fails.
Date: Wed, 19 Jan 2011 01:38:31 -0200
Message-ID: <20110119033831.GB7762@joana>
References: <alpine.LNX.2.00.1101140000541.11347@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Marcel Holtmann <marcel@holtmann.org>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:65374 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752643Ab1ASDic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 22:38:32 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1101140000541.11347@swampdragon.chaosbits.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesper,

* Jesper Juhl <jj@chaosbits.net> [2011-01-14 00:18:49 +0100]:

> If alloc_skb() fails in read_index_list() we'll return -ENOMEM without 
> releasing 'hci_dev_list_lock'.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> ---
>  mgmt.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)

Patch has been applied. Thanks.

-- 
Gustavo F. Padovan
http://profusion.mobi
