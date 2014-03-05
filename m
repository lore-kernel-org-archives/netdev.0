From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 0/2] af_key: fixes for sleeping while atomic
Date: Wed, 5 Mar 2014 13:07:01 +0100
Message-ID: <20140305120701.GQ32371@secunet.com>
References: <20140227151954.GA30946@redhat.com>
 <1393935984-8733-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Paul Moore <paul@paul-moore.com>,
	Dave Jones <davej@redhat.com>, Fan Du <fan.du@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:52453 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756790AbaCEMHF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 07:07:05 -0500
Content-Disposition: inline
In-Reply-To: <1393935984-8733-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 04, 2014 at 01:26:22PM +0100, Nikolay Aleksandrov wrote:
> Hi,
> The first patch takes care of the issue on the af_key side, and the second
> one fixes it on the selinux side (security_xfrm_policy_alloc).
> There're a few lines >80 but they were already long, I'm not sure if breaking
> them above the limit would make them more readable than they already are.
> 
> Best regards,
>  Nikolay Aleksandrov
> 
> CC: Paul Moore <paul@paul-moore.com>
> CC: Dave Jones <davej@redhat.com>
> CC: Steffen Klassert <steffen.klassert@secunet.com>
> CC: Fan Du <fan.du@windriver.com>
> CC: David S. Miller <davem@davemloft.net>
> 
> Nikolay Aleksandrov (2):
>   net: af_key: fix sleeping under rcu
>   selinux: add gfp argument to security_xfrm_policy_alloc and fix
>     callers
> 

Looks ok. I'd take both patches into the ipsec tree, but I want to see
an ack from Paul because this touches IPsec and selinux code.
