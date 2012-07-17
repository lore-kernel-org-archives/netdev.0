From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] ipvs fixes for 3.5
Date: Tue, 17 Jul 2012 03:20:19 -0700 (PDT)
Message-ID: <20120717.032019.709646685929292798.davem@davemloft.net>
References: <1342519589-3348-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48619 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755244Ab2GQKUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 06:20:20 -0400
In-Reply-To: <1342519589-3348-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: pablo@netfilter.org
Date: Tue, 17 Jul 2012 12:06:27 +0200

> I know that we're in fairly late stage to request pulls, but the IPVS people
> pinged me with little patches with oops fixes last week.
> 
> One of them was recently introduced (during the 3.4 development cycle) while
> cleaning up the IPVS netns support. They are:
> 
> * Fix one regression introduced in 3.4 while cleaning up the
>   netns support for IPVS, from Julian Anastasov.
> 
> * Fix one oops triggered due to resetting the conntrack attached to the skb
>   instead of just putting it in the forward hook, from Lin Ming. This problem
>   seems to be there since 2.6.37 according to Simon Horman.
> 
> You can pull these changes from:
> 
> git://1984.lsi.us.es/nf master

Pulled, thanks Pablo.
