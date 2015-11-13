From: Jens Axboe <axboe@kernel.dk>
Subject: 4.3.0+ breaks software VPN
Date: Fri, 13 Nov 2015 14:37:00 -0700
Message-ID: <564657FC.4050206@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:34214 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751358AbbKMVhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 16:37:04 -0500
Received: by igvg19 with SMTP id g19so44388583igv.1
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2015 13:37:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Tried to connect to sw vpn today, and it isn't working. Running git 
as-of yesterday. In dmesg:

[23703.921542] vpn0: set_features() failed (-1); wanted 
0x00000080000048c1, left 0x00000080001b48c9

Reverting:

fd867d51f889
5ba3f7d61a3a
e7868a85e1b2

in reverse order makes it work again. How do we get this fixed so that 
4.4-rc1 doesn't break basic VPN support?

-- 
Jens Axboe
