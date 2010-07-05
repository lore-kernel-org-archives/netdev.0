From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Distributed Switch Architecture(DSA)
Date: Mon, 5 Jul 2010 19:24:04 +0200
Message-ID: <20100705172404.GG14513@mail.wantstofly.org>
References: <20100618095923.GC14513@mail.wantstofly.org> <OF8E185B56.9B8AB610-ONC1257746.003A78DF-C1257746.003D4C6C@transmode.se> <20100618121223.GH14513@mail.wantstofly.org> <OF4FC7639D.8FBCAF3B-ONC1257746.004AF9D3-C1257746.005397F6@transmode.se> <20100618201243.GK14513@mail.wantstofly.org> <OF27FDE4E4.06C565FF-ONC1257747.004A175A-C1257747.004EF252@transmode.se> <20100619165642.GP14513@mail.wantstofly.org> <OF9D3E1FC3.D7320E72-ONC1257747.0066095A-C1257747.006751E1@transmode.se> <20100619185739.GQ14513@mail.wantstofly.org> <OFE5DDA53C.8EDE0B1A-ONC1257748.00467368-C1257748.0050B4A2@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:36878 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349Ab0GERYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 13:24:13 -0400
Content-Disposition: inline
In-Reply-To: <OFE5DDA53C.8EDE0B1A-ONC1257748.00467368-C1257748.0050B4A2@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 20, 2010 at 04:41:31PM +0200, Joakim Tjernlund wrote:

> > > If not, what is the point of DSA then if it doesn't use the native
> > > forwarding capabilities of the HW switch?
> >
> > The point is and always was to provide a framework for proper integration
> > of hardware switch chips into the Linux kernel.  This framework doesn't
> > become useless just because it doesn't already support every single
> > hardware feature at this point.
> 
> Right, sorry if I sounded a bit harsh.
> 
> So DSA currently does a very minimal config of the HW switch to get
> things going.

Correct.


> If you want to do something more fancy one has to
> add a control plane to DSA which would possibly talk
> to a user space app. Is that correct?

Yes and no -- yes in the sense that if you want to use more functionality
of the switch chip, you'll have to add some code that extracts that info
from the Linux network interface config and turns it into commands for the
switch chip, and no in the sense that I'm not sure yet what the best way
to implement this would be.  (Doing it all in userspace is one option.)
