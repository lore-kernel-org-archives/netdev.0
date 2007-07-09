From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Fix gen_estimator timer removal race
Date: Mon, 09 Jul 2007 15:30:36 -0700 (PDT)
Message-ID: <20070709.153036.24205948.davem@davemloft.net>
References: <468BC127.1090904@trash.net>
	<20070705054801.GA1569@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@o2.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48662
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754334AbXGJD3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 23:29:38 -0400
In-Reply-To: <20070705054801.GA1569@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@o2.pl>
Date: Thu, 5 Jul 2007 07:48:01 +0200

> On Wed, Jul 04, 2007 at 05:47:51PM +0200, Patrick McHardy wrote:
> > This is an updated version of the gen_estimator fix
> > that relies on all changes happening under the rtnl
> > and just fixes the race between timer rearming and
> > timer removal.
> > 
> > 
> 
> > [NET]: Fix gen_estimator timer removal race
> > 
> > As noticed by Jarek Poplawski <jarkao2@o2.pl>, the timer removal in
> > gen_kill_estimator races with the timer function rearming the timer.
> > 
> > Check whether the timer list is empty before rearming the timer
> > in the timer function to fix this.
> > 
> > Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> Acked-by: Jarek Poplawski <jarkao2@o2.pl>

Applied, thanks guys.
