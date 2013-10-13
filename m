From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH 2/2] ixgbe: enable l2 forwarding acceleration for macvlans
Date: Sun, 13 Oct 2013 13:48:33 -0700
Message-ID: <525B0721.7060709@gmail.com>
References: <1380140209-24587-1-git-send-email-nhorman@tuxdriver.com> <1381517037-26007-1-git-send-email-nhorman@tuxdriver.com> <1381517037-26007-3-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:61087 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755160Ab3JMUsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 16:48:54 -0400
Received: by mail-oa0-f49.google.com with SMTP id j10so1095751oah.8
        for <netdev@vger.kernel.org>; Sun, 13 Oct 2013 13:48:54 -0700 (PDT)
In-Reply-To: <1381517037-26007-3-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/11/2013 11:43 AM, Neil Horman wrote:
> Now that l2 acceleration ops are in place from the prior patch, enable ixgbe to
> take advantage of these operations.  Allow it to allocate queues for a macvlan
> so that when we transmit a frame, we can do the switching in hardware inside the
> ixgbe card, rather than in software.
>
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: john.fastabend@gmail.com
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: "David S. Miller" <davem@davemloft.net>
> ---

Neil, I'm fairly sure I can simplify this patch further. I'll be able
to take a shot at it Tuesday if you don't mind waiting.

I can resubmit the series then and preserve your signed-off on at least
the first patch. Seem reasonable?

.John

-- 
John Fastabend         Intel Corporation
