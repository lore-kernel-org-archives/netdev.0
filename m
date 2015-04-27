From: Jiri Slaby <jslaby@suse.cz>
Subject: [stable request] mlx4 & dev_kfree_skb [was: [PATCHES] Networking]
Date: Mon, 27 Apr 2015 11:10:51 +0200
Message-ID: <553DFD1B.5000304@suse.cz>
References: <20150421.143012.2106864724544609194.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: stable <stable@vger.kernel.org>, ML netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:34640 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932372AbbD0JKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 05:10:55 -0400
In-Reply-To: <20150421.143012.2106864724544609194.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/21/2015, 08:30 PM, David Miller wrote:
> Please queue up the following networking bug fixes for 3.12, 3.14, 3.18,
> 3.19, and 4.0 -stable, respectively.

Hi,

similar to other "Call dev_kfree_skby_any instead of dev_kfree_skb.", I
believe, that mlx4 (only) in 3.14 should receive the fix too:

commit e81f44b66b456a7dcfbdeffeb355458cd6a58973
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Tue Mar 11 14:19:14 2014 -0700

    mlx4: Call dev_kfree_skby_any instead of dev_kfree_skb.


In 3.12, it calls dev_kfree_skb_any yet.
In 3.14, it was changed to dev_kfree_skb.
In 3.18, it was changed to dev_consume_skb_any.

So please consider the commit above for the next 3.14 update.

thanks,
-- 
js
suse labs
