From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: 4.3.0+ breaks software VPN
Date: Fri, 13 Nov 2015 22:44:11 +0100
Message-ID: <564659AB.2080308@cumulusnetworks.com>
References: <564657FC.4050206@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jens Axboe <axboe@kernel.dk>, Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35530 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302AbbKMVoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 16:44:15 -0500
Received: by wmdw130 with SMTP id w130so45786721wmd.0
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2015 13:44:13 -0800 (PST)
In-Reply-To: <564657FC.4050206@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/2015 10:37 PM, Jens Axboe wrote:
> Hi,
> 
> Tried to connect to sw vpn today, and it isn't working. Running git as-of yesterday. In dmesg:
> 
> [23703.921542] vpn0: set_features() failed (-1); wanted 0x00000080000048c1, left 0x00000080001b48c9
> 
> Reverting:
> 
> fd867d51f889
> 5ba3f7d61a3a
> e7868a85e1b2
> 
> in reverse order makes it work again. How do we get this fixed so that 4.4-rc1 doesn't break basic VPN support?
> 

Today I've posted a patch that should fix this,
http://patchwork.ozlabs.org/patch/544307/

More testing is always welcome.

Cheers,
 Nik
