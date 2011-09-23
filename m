From: David Lamparter <equinox@diac24.net>
Subject: Re: Introducing open source MSTP daemon
Date: Fri, 23 Sep 2011 14:30:58 +0200
Message-ID: <20110923123058.GD1012103@jupiter.n2.diac24.net>
References: <201109221727.33010.vitas@nppfactor.kiev.ua>
 <20110922163939.GB1012103@jupiter.n2.diac24.net>
 <201109231036.05039.vitas@nppfactor.kiev.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	"Srinivas M.A." <srinivas.aji@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:45368 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753633Ab1IWMba (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Sep 2011 08:31:30 -0400
Content-Disposition: inline
In-Reply-To: <201109231036.05039.vitas@nppfactor.kiev.ua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 23, 2011 at 10:36:04AM +0300, Vitalii Demianets wrote:
> I suppose these questions are not related to kernel development so I suggest 
> to continue discussion on above topics at the project discussion board:
> http://sourceforge.net/p/mstpd/discussion/

That's a forum - I'm afraid that's not quite a good communication
channel for software development feedback. A "normal" software developer
probably has 10, 20, 30... packages he follows around; if each of them
was using a separate discussion forum, the developer would have to check
30 forums regularly, in hir browser.

A mailing list delivers all of that discussion to the developer's
mailbox where it's very easy to sort, follow & respond. Considering the
probably rather low traffic, an existing list might even do it.

> > I assume it works with current Linux kernel bridge code on a RSTP level?
> > The code looks considerably more maintainable than rstpd :) - I will try
> > running it later!
> >
> Sorry, at the moment function MSTP_OUT_set_state() does nothing except 
> logging. But it is valueable thought: although MSTI states do not have 
> meaning to the kernel bridge code, CIST states can be used to control bridge 
> slave states, so mstpd can replace rstpd as more generic (and conforming to 
> more recent standard).

Well, with the current kernel code you can basically support MSTP setups
where all VLANs are mapped to one MSTI, since there's just one port
state for all VLANs. As far as I can tell, that doesn't need to be
the CIST/instance 0, as long as it's the same for all VLANs.

> Anyways, the code is basically untested. It compiles and runs in my setup, 
> that's all for now. But I somehow have gut feeling that the code is mature 
> enough to be put for the community consideration.

Well, "the community" is usually happy when you continually maintain and
improve your code - one-shot code publications ("fire & forget") happen
all too often and are forgotten quickly...


-David
