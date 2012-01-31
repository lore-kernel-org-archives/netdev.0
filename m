From: augusto <augusto@proscend.com>
Subject: Re: Introducing open source MSTP daemon
Date: Tue, 31 Jan 2012 09:38:33 +0000 (UTC)
Message-ID: <loom.20120131T103325-267@post.gmane.org>
References: <201109221727.33010.vitas@nppfactor.kiev.ua> <20110922163939.GB1012103@jupiter.n2.diac24.net> <201109281256.19713.vitas@nppfactor.kiev.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:53233 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752635Ab2AaJpP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jan 2012 04:45:15 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1RsAGu-0005mk-CW
	for netdev@vger.kernel.org; Tue, 31 Jan 2012 10:45:05 +0100
Received: from 122-120-37-159.dynamic.hinet.net ([122.120.37.159])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2012 10:45:04 +0100
Received: from augusto by 122-120-37-159.dynamic.hinet.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2012 10:45:04 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vitalii Demianets <vitas <at> nppfactor.kiev.ua> writes:

> 
> On Thursday 22 September 2011 19:39:40 David Lamparter wrote:
> >
> > I assume it works with current Linux kernel bridge code on a RSTP level?
> > The code looks considerably more maintainable than rstpd :) - I will try
> > running it later!
> >
> 
> Ok, now it works with kernel bridge code and you can evaluate it.
> 
> mstpd sends all the state changes in the CIST to the kernel bridge, so it 
> works for the (R)STP cases as expected. Checked it by connecting two bridges: 
> one running mstpd and another running rstpd and in-kernel stp. In both cases 
> mstpd code behaves reasonably. Not checked in more complex setups though.
> 
> Also mstpd translates to the bridge code fdb flushing events and changes 
> ageing time (for the rapid ageing case).
> 


Hi Vitalii,

Thanks for your work.

I am trying to implement your solution on an embedded system, but I dont have a 
clear idea of how to use it.

My scenario is like this:

eth0.2 and eth1.2 belong to br1
eth0.4 and eth3.4 belong to br2
eth1.5 and eth3.5 belong to br3

I added br1 br2 and br3 to bridge-stp.

What steps should I take now?

Thanks for your help

Augusto
