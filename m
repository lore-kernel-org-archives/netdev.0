From: "Goff, Thomas" <Thomas.Goff@boeing.com>
Subject: Re: [PATCH] netlink: use the appropriate namespace pid
Date: Tue, 30 Mar 2010 19:42:33 -0700
Message-ID: <6AFD35BEDB60334C9A31FD694E13EF0D22C2F29EF0@XCH-NW-18V.nw.nos.boeing.com>
References: <20100321.213022.22037430.davem@davemloft.net><b6fcc0a1003240058
	i524c95eere17c1349d14267b1@mail.gmail.com><b6fcc0a1003240119h7c26d649taa1f947c2aeb6064@mail.gmail.com>
 <20100326.201426.05866973.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "adobriyan@gmail.com" <adobriyan@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"adobriyan@openvz.org" <adobriyan@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blv-smtpout-01.boeing.com ([130.76.32.69]:56056 "EHLO
	blv-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756659Ab0CaCmr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 22:42:47 -0400
In-Reply-To: <20100326.201426.05866973.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <mailto:davem@davemloft.net>
Sent: Friday, March 26, 2010 8:14 PM

> > re netns sched patch:
> > 
> > * in psched_open() PDE(inode)->data isn't needed because
> >   it isn't used -- just pass NULL.
> > * drop useless trailing return; in psched_net_exit() :^)
> > * sch_mirred.c still won't work in netns
> 
> Tom, please send a patch to fixup these issues.

Sorry for the delayed response.  A patch I'll send separately
addresses the first two comments.  The act_mirred.c issue is a
little more involved and I'll try to submit a preliminary patch
and request comments later this week.

  Tom
