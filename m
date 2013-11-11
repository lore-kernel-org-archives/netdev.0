From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] xfrm: check function pointer of xfrm_mgr
 before use it
Date: Mon, 11 Nov 2013 10:52:22 -0800
Message-ID: <20131111105222.4857587a@samsung-9>
References: <1384093556-8987-1-git-send-email-baker.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	steffen.klassert@secunet.com, netdev@vger.kernel.org
To: baker.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:62415 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754197Ab3KKSwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 13:52:34 -0500
Received: by mail-pb0-f48.google.com with SMTP id mc17so3279030pbc.21
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 10:52:33 -0800 (PST)
In-Reply-To: <1384093556-8987-1-git-send-email-baker.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 10 Nov 2013 22:25:56 +0800
baker.kernel@gmail.com wrote:

> For current kernel source, there is no problem.
> 
> In our vpn product, we need a xfrm_km in kernel module
> to monitor the xfrm state change.
> thus, the 'acquire' and 'compile_policy' may be NULL.
> 
> So I think we should do the check before use it

The upstream kernel does not accept or make changes to accommodate code that
is not part of the kernel source.

The only way this change would be considered would be as part of a submission
of the kernel module. I.e. part 1 of N.

So if you are willing to submit your module upstream under GPLv2, then
it will be reviewed an possibly accepted. If you just want this change to
make your product easier, then sorry no.
