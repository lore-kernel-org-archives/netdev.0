From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] net/flow: fix fc->percpu NULL pointer dereference
Date: Fri, 9 Jun 2017 10:32:55 +0200
Message-ID: <20170609083255.GR22049@secunet.com>
References: <1496996036-22077-1-git-send-email-liuhangbin@gmail.com>
 <CAPwn2JSeKnspZpnWTXsze7sCSXJ9mbq2K3-mu-muuy8iT4A1qw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>,
        Xin Long <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:44890 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751505AbdFIIc7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Jun 2017 04:32:59 -0400
Content-Disposition: inline
In-Reply-To: <CAPwn2JSeKnspZpnWTXsze7sCSXJ9mbq2K3-mu-muuy8iT4A1qw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 09, 2017 at 04:23:01PM +0800, Hangbin Liu wrote:
> Hi Steffen,
> 
> BTW, If we put the check in xfrm_policy_flush(), we can prevent it earlier.
> But If we put the check in flow_cache_percpu_empty(), we can prevent
> other functions set fc->percpu to NULL, although not much possible : )
> 
> So I'm not quite sure whether we should put the check in
> flow_cache_percpu_empty() or in xfrm_policy_flush().

Can't we just call xfrm_policy_fini() first and then flow_cache_fini()?
