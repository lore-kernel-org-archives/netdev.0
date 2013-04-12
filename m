From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] lsm: export the security_skb_owned_by() function
Date: Fri, 12 Apr 2013 14:51:51 -0400
Message-ID: <11802724.2ypFIKMpj2@sifl>
References: <20130412154300.26512.67761.stgit@localhost> <20130412.133943.1398967886487919460.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51617 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752491Ab3DLSvy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Apr 2013 14:51:54 -0400
In-Reply-To: <20130412.133943.1398967886487919460.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, April 12, 2013 01:39:43 PM David Miller wrote:
> From: Paul Moore <pmoore@redhat.com>
> Date: Fri, 12 Apr 2013 11:43:00 -0400
> 
> > Another bit we missed when adding the skb_owned_by() hook.
> > 
> > Signed-off-by: Paul Moore <pmoore@redhat.com>
> 
> CONFIG_SECURITY is a bool, as is ipv4, so neither the definition
> nor the call sites can be modular.
> 
> Therefore no export is needed.

Yep, sorry about that.

-- 
paul moore
security and virtualization @ redhat
