From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net:ethernet:aquantia:atlantic: Switch to use
 napi_gro_receive
Date: Thu, 04 May 2017 10:42:57 -0400 (EDT)
Message-ID: <20170504.104257.1536182180703411206.davem@davemloft.net>
References: <16bc94e6bb9cc977a9a9e0cac48ae91ff7198f05.1493829200.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, darcari@redhat.com
To: Pavel.Belous@aquantia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55396 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751565AbdEDOm6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 10:42:58 -0400
In-Reply-To: <16bc94e6bb9cc977a9a9e0cac48ae91ff7198f05.1493829200.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <Pavel.Belous@aquantia.com>
Date: Wed,  3 May 2017 19:57:10 +0300

> From: Pavel Belous <pavel.belous@aquantia.com>
> 
> Add support for GRO (generic receive offload) for aQuantia Atlantic driver.
> This results in a perfomance improvement when GRO is enabled.
> 
> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>

Please format your Subject line properly.

You have _way_ too many subsystem prefixes, and when there are more
than one they should be separated by spaces like "a: b: c:"

In this case an appropriate Subject line would be:

[PATCH net-next] aquantia: Switch to use napi_gro_receive().

But since this is a new feature, and the net-next tree is currently
closed, you will have to resubmit this when the net-next tree
opens.

Thank you.
