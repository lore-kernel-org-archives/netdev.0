From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: xfrm: Fix initialize repl field of struct xfrm_state
Date: Tue, 22 Mar 2011 14:14:14 +0100
Message-ID: <20110322131413.GC1290@secunet.com>
References: <4D86E603.8080704@cn.fujitsu.com>
 <20110320.225542.71119753.davem@davemloft.net>
 <4D86F1FD.3080009@cn.fujitsu.com>
 <20110320.234606.183056322.davem@davemloft.net>
 <20110321082512.GB27581@secunet.com>
 <4D871607.6090508@cn.fujitsu.com>
 <4D8717DA.2010901@cn.fujitsu.com>
 <20110321120635.GA1290@secunet.com>
 <4D87F5A6.90704@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36058 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752154Ab1CVNOQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2011 09:14:16 -0400
Content-Disposition: inline
In-Reply-To: <4D87F5A6.90704@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 22, 2011 at 09:04:38AM +0800, Wei Yongjun wrote:
> 
> BTW, looking into more about this, another path, XFRM_MSG_NEWAE,
> can overwrite the x->replay_esn with the nla_data length, which
> may larger then the size we malloc.
> 

Yes, I've noticed that yesterday too. I'll fix it up.

Thanks!
