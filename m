From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Wed, 29 Aug 2007 15:13:01 -0700
Message-ID: <20070829151301.495f3d6e@freepuppy.rosehill.hemminger.net>
References: <200708292052.NAA21975@tardy.cup.hp.com>
	<5640c7e00708291432q6acde704od52247647a6b453@mail.gmail.com>
	<20070829.144656.104048365.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ian.mcdonald@jandi.co.nz, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51941 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758460AbXH2WNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 18:13:09 -0400
In-Reply-To: <20070829.144656.104048365.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Aug 2007 14:46:56 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
> Date: Thu, 30 Aug 2007 09:32:38 +1200
> 
> > So I'm suspecting that the default should be changed to 1000 to match
> > the RFC which would solve this issue. I note that the RFC is a SHOULD
> > rather than a MUST. I had a quick look around and not sure why Linux
> > overrides the RFC on this one.
> 
> Everyone uses this value, even BSD since ancient times.
> 
> None of the research folks want to commit to saying a lower value is
> OK, even though it's quite clear that on a local 10 gigabit link a
> minimum value of even 200 is absolutely and positively absurd.
> 
> So what do these cellphone network people want to do, increate the
> minimum RTO or increase it?  Exactly how does it help them?
> 
> If the issue is wireless loss, algorithms like FRTO might help them,
> because FRTO tries to make a distinction between capacity losses
> (which should adjust cwnd) and radio losses (which are not capacity
> based and therefore should not affect cwnd).


The following could help with loss.
There was some discussion about implementing TCP NCR (RFC4653)
and Narasimha Reddy said he might have something that could be used.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
