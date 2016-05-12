From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 05/13] fou: Add encap ops for IPv6 tunnels
Date: Thu, 12 May 2016 22:26:28 +0300
Message-ID: <20160512222628.271079a1@halley>
References: <1462985253-2380625-1-git-send-email-tom@herbertland.com>
	<1462985253-2380625-6-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34994 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752863AbcELT0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 15:26:40 -0400
Received: by mail-wm0-f66.google.com with SMTP id e201so17620443wme.2
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 12:26:40 -0700 (PDT)
In-Reply-To: <1462985253-2380625-6-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, 11 May 2016 09:47:25 -0700 Tom Herbert <tom@herbertland.com> wrote:
> This patch adds IP tunnel encapsulation operations for IPv6. This
> includes the infrastructure to add and delete operations. IPv6 variants
> of fou6_build_header and gue6_build_header are added in a new
> fou6 module. These encapsulation operations for fou and gue are
> automatically added when the fou6 module loads.

One small nit:

> +EXPORT_SYMBOL(fou6_build_header);

[snip]

> +EXPORT_SYMBOL(gue6_build_header);

As with previous patch, seems these needn't be exported. Am I missing
something here?

Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Regards,
Shmulik
