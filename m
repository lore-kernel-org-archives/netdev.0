From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] net-tcp: Fast Open base
Date: Mon, 16 Jul 2012 23:16:44 -0700 (PDT)
Message-ID: <20120716.231644.1189536600250332545.davem@davemloft.net>
References: <1342473410-6265-1-git-send-email-ycheng@google.com>
	<1342473410-6265-2-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, edumazet@google.com, ncardwell@google.com,
	sivasankar@cs.ucsd.edu, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346Ab2GQGQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 02:16:44 -0400
In-Reply-To: <1342473410-6265-2-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Mon, 16 Jul 2012 14:16:44 -0700

> +#define TCPOPT_EXP		254	/* Experimental */
> +/* Magic number to be after the option value for sharing TCP
> + * experimental options. See draft-ietf-tcpm-experimental-options-00.txt
> + */
> +#define TCPOPT_FASTOPEN_MAGIC	0xF989

If I apply this, we're stuck supporting this experimental number
forever.

Because somewhere, someone will have a kernel running using this
number, so we have to support this option value as well as whatever
the official one is.

Therefore I think the only logical thing we can do is only deploy
this once an official option number is choosen.
