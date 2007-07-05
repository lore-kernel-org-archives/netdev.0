From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [NET]: Fix gen_estimator timer removal race
Date: Thu, 5 Jul 2007 07:48:01 +0200
Message-ID: <20070705054801.GA1569@ff.dom.local>
References: <468BC127.1090904@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:48792 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754789AbXGEFjk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2007 01:39:40 -0400
Content-Disposition: inline
In-Reply-To: <468BC127.1090904@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 04, 2007 at 05:47:51PM +0200, Patrick McHardy wrote:
> This is an updated version of the gen_estimator fix
> that relies on all changes happening under the rtnl
> and just fixes the race between timer rearming and
> timer removal.
> 
> 

> [NET]: Fix gen_estimator timer removal race
> 
> As noticed by Jarek Poplawski <jarkao2@o2.pl>, the timer removal in
> gen_kill_estimator races with the timer function rearming the timer.
> 
> Check whether the timer list is empty before rearming the timer
> in the timer function to fix this.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Acked-by: Jarek Poplawski <jarkao2@o2.pl>
