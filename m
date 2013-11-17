From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: oops in pskb_expand_head - 3.11.6
Date: Sun, 17 Nov 2013 20:18:10 +0100
Message-ID: <20131117191810.GH16541@order.stressinduktion.org>
References: <20131116231615.GA24327@marquez.int.rhx> <20131116234223.GG16541@order.stressinduktion.org> <20131117111150.GC24327@marquez.int.rhx>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: Michele Baldessari <michele@acksyn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:48581 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360Ab3KQTSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Nov 2013 14:18:12 -0500
Content-Disposition: inline
In-Reply-To: <20131117111150.GC24327@marquez.int.rhx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 17, 2013 at 11:11:50AM +0000, Michele Baldessari wrote:
> Hi Hannes,
> 
> On Sun, Nov 17, 2013 at 12:42:23AM +0100, Hannes Frederic Sowa wrote:
> > On Sat, Nov 16, 2013 at 11:16:15PM +0000, Michele Baldessari wrote:
> > > Two oops like the following were reported in Fedora 19 - kernel 3.11.6:
> > > https://bugzilla.redhat.com/show_bug.cgi?id=1015905
> > 
> > I have not followed that issue that closely, but could you try linus tree
> > or net-next?
> > 
> > Maybe those two patches improve the situation:
> > https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=9037c3579a277f3a23ba476664629fda8c35f7c4
> > https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=6aafeef03b9d9ecf255f3a80ed85ee070260e1ae
> > 
> indeed a current kernel seems to fix the crash (according to the
> reporters). I'll see if I manage to bisect exactly.

Great, if you confirm this we can ask David if he adds the commits to the
-stable queue.

Greetings,

  Hannes
