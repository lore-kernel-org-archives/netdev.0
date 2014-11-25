From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] gre: Set inner mac header in gro complete
Date: Tue, 25 Nov 2014 09:57:21 -0800
Message-ID: <1416938241.29427.37.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416936611-22702-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux@stwm.de, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:41039 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328AbaKYR5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 12:57:24 -0500
Received: by mail-ie0-f175.google.com with SMTP id at20so1035391iec.20
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 09:57:23 -0800 (PST)
In-Reply-To: <1416936611-22702-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-11-25 at 09:30 -0800, Tom Herbert wrote:
> Set the inner mac header to point to the GRE payload when
> doing GRO. This is needed if we proceed to send the packet
> through GRE GSO which now uses the inner mac header instead
> of inner network header to determine the length of encapsulation
> headers.
> 
> Reported-by: Wolfgang Walter <linux@stwm.de>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---

Please Tom, add in your bug fixes something to ease backports.

Fixes: 14051f0452a2 ("gre: Use inner mac length when computing tunnel length")
