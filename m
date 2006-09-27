From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Customizable TCP backoff patch
Date: Wed, 27 Sep 2006 16:00:44 -0700
Message-ID: <20060927160044.68ffca2e@freekitty>
References: <451AC889.5000407@redhat.com>
	<20060927.161638.62343616.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: woodard@redhat.com, netdev@vger.kernel.org, mgrondona@llnl.gov,
	behlendorf1@llnl.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:56012 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1031255AbWI0Xl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 19:41:58 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060927.161638.62343616.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 27 Sep 2006 16:16:38 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Ben Woodard <woodard@redhat.com>
> Date: Wed, 27 Sep 2006 11:52:57 -0700
> 
> > Because these are general utility clusters we run many different 
> > programs and so trying to fix this problem in the application is not 
> > possible since there are literally hundreds if not thousands of them.
> 
> Then why add a socket option setting as your patch does? :-)
> 
> I also object to the socket option setting being allowed for
> any user because this can have awful effects if allowed by
> arbitrary users on arbitrary networks.

Setting a cwnd limit would do the same thing.
