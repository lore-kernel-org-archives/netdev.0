From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] ipv6: fix a potential NULL deref
Date: Tue, 30 Oct 2012 09:44:10 +0800
Message-ID: <1351561450.3556.0.camel@cr0>
References: <1351493366.8221.2.camel@cr0>
	 <1351494334.7394.64.camel@edumazet-glaptop> <1351495523.8221.8.camel@cr0>
	 <20121029.132936.191100167150004535.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15502 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750731Ab2J3BoU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 21:44:20 -0400
In-Reply-To: <20121029.132936.191100167150004535.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-29 at 13:29 -0400, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Mon, 29 Oct 2012 15:25:23 +0800
> 
> > But this will be a problem if someone moved dst inside rt, as there
> > is no comment saying dst has to be the first one?
> 
> If we move the initial dst member, many things that depend upon it
> being first will have to change.
> 
> Your change was unnecessary and inappropriate, and let's just leave
> it at that.

Yeah, that is why I sent:
http://marc.info/?l=linux-netdev&m=135150561014916&w=2

:)
