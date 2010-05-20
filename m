From: =?ISO-8859-1?Q?Sjur_Br=E6ndeland?= <sjurbren@gmail.com>
Subject: Re: [PATCH net-next-2.6 0/8] CAIF: Bugfixes and updates
Date: Thu, 20 May 2010 23:08:27 +0200
Message-ID: <AANLkTilvQ8W5X-qvt6GvEj-1ZmmfwZJz079Rdi8K6Tll@mail.gmail.com>
References: <1274341448-14924-1-git-send-email-sjur.brandeland@stericsson.com>
	 <20100520.005658.11949785.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: sjur.brandeland@stericsson.com, netdev@vger.kernel.org,
	marcel@holtmann.org, daniel.martensson@stericsson.com,
	linus.walleji@stericsson.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38220 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754689Ab0ETVI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 17:08:29 -0400
Received: by fxm5 with SMTP id 5so250904fxm.19
        for <netdev@vger.kernel.org>; Thu, 20 May 2010 14:08:27 -0700 (PDT)
In-Reply-To: <20100520.005658.11949785.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

David Miller wrote:
> Send me bug fixes only.

Currently in caif_socket.c caif_seqpkt_recvmsg returns -EMSGSIZE if
skb don't fit in user buffer.
Would you consider my patch where I fix MSG_TRUNC to work properly a bugfix?

Regards Sjur
