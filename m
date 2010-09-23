From: Mikko Vinni <mmvinni@yahoo.com>
Subject: Re: [PATCH] br2684: fix scheduling while atomic
Date: Thu, 23 Sep 2010 09:51:24 -0700 (PDT)
Message-ID: <538742.564.qm@web58407.mail.re3.yahoo.com>
References: <20100922144329.0cb3cf86@thirdoffive.cmf.nrl.navy.mil> <1285242654-9891-1-git-send-email-karl@hiramoto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, chas@cmf.nrl.navy.mil,
	Karl Hiramoto <karl@hiramoto.org>
To: Karl Hiramoto <karl@hiramoto.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web58407.mail.re3.yahoo.com ([68.142.236.175]:24468 "HELO
	web58407.mail.re3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754392Ab0IWQvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 12:51:25 -0400
In-Reply-To: <1285242654-9891-1-git-send-email-karl@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karl Hiramoto <karl@hiramoto.org>
> Subject: [PATCH] br2684: fix scheduling while atomic
> 
> You can't call atomic_notifier_chain_unregister() while in atomic  context.
> 
> Fix, call un/register_atmdevice_notifier in module __init and  __exit.
> 
> Bug  report:
> http://comments.gmane.org/gmane.linux.network/172603
> 
> Signed-off-by:  Karl Hiramoto <karl@hiramoto.org>

Feel free to add

Reported-and-tested-by: Mikko Vinni <mmvinni@yahoo.com>

Seems to be fixed as advertized, i.e., nothing suspicious appeared in
the logs when opening/closing connection, killing br2684ctl, or
loading/unloading the br2684 module.


Thanks

Mikko


> ---
>   net/atm/br2684.c |   12 ++----------
>  1 files changed, 2 insertions(+),  10 deletions(-)
> 
> diff --git a/net/atm/br2684.c b/net/atm/br2684.c
> index  651babd..ad2b232 100644


      
