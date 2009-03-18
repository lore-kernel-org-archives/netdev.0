From: David Miller <davem@davemloft.net>
Subject: Re: High contention on the sk_buff_head.lock
Date: Wed, 18 Mar 2009 14:38:44 -0700 (PDT)
Message-ID: <20090318.143844.173112261.davem@davemloft.net>
References: <87prge1rhu.fsf@basil.nowhere.org>
	<20090318.140340.55290859.davem@davemloft.net>
	<49C16349.9030503@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org
To: vernux@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46258
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751644AbZCRVi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 17:38:58 -0400
In-Reply-To: <49C16349.9030503@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vernon Mauery <vernux@us.ibm.com>
Date: Wed, 18 Mar 2009 14:10:33 -0700

> David Miller wrote:
> > From: Andi Kleen <andi@firstfloor.org>
> > Date: Wed, 18 Mar 2009 21:54:37 +0100
> > 
> >> But then again I'm not sure it's  worth it if the problem only
> >> happens in out of tree RT.
> > The list of problems that only show up with the RT kernel seems to be
> > constantly increasing, but honestly is very surprising to me.
> > I don't understand why we even need to be concerned about this stuff
> > upstream, to be honest.
> > Please reproduce this in the vanilla kernel, then get back to us.
> 
> Huh? The numbers that I posted *were* from the vanilla kernel. I ran
> the 2.6.29-rc8 kernel with lock_stat enabled.  The lock contention
> happens on the same lock in both vanilla and -rt, it just happens
> to be more pronounced in the -rt kernel because of the double context
> switches that the sleeping spinlock/rt-mutexes introduce.

And the double context switches are probably also why less
natural batching and locality are achieved in the RT kernel.

Isn't that true?
