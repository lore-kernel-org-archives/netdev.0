From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH v5 net-next 03/14] ipv6: Fix nexthdr for reinjection
Date: Mon, 16 May 2016 21:19:25 +0300
Message-ID: <20160516211925.1498653f@halley>
References: <1463355755-3481375-1-git-send-email-tom@herbertland.com>
	<1463355755-3481375-4-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35056 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753491AbcEPSTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 14:19:34 -0400
Received: by mail-wm0-f67.google.com with SMTP id e201so19908432wme.2
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 11:19:33 -0700 (PDT)
In-Reply-To: <1463355755-3481375-4-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sun, 15 May 2016 16:42:24 -0700 Tom Herbert <tom@herbertland.com> wrote:
> In ip6_input_finish the nexthdr protocol is retrieved from the
> next header offset that is returned in the cb of the skb.
> This method does not work for UDP encapsulation that may not
> even have a concept of a nexthdr field (e.g. FOU).
> 
> This patch checks for a final protocol (INET6_PROTO_FINAL) when a
> protocol handler returns > 1. If the protocol is not final then

If you respin due to other reasons:  s/> 1/> 0/

> resubmission is performed on nhoff value. If the protocol is final
> then the nexthdr is taken to be the return value.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
