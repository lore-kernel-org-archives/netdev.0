From: Hemant-vilas RAMDASI <hemant.ramdasi@stericsson.com>
Subject: RE: [PATCH] Phonet: set the pipe handle using setsockopt
Date: Wed, 16 Nov 2011 09:46:07 +0100
Message-ID: <81C3A93C17462B4BBD7E272753C105791FB0A0F045@EXDCVYMBSTM005.EQ1STM.local>
References: <1321257210-17200-1-git-send-email-hemant.ramdasi@stericsson.com>
 <2168215.tYVKKNoJjY@hector>
 <81C3A93C17462B4BBD7E272753C105791FB090B0B8@EXDCVYMBSTM005.EQ1STM.local>
 <3443203.gVgdO3ogFg@hector>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: =?iso-8859-1?Q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont@nokia.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:36624 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755132Ab1KPIqP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 03:46:15 -0500
In-Reply-To: <3443203.gVgdO3ogFg@hector>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remi,

> > > > +#define SIOPNPIPE_ENABLE	_IO(SIOCPNGAUTOCONF,   1)
> > >
> > > Does this even work? I am not an expert on this, but I would think
> that
> > > device-private controls are routed to the network device, not the
> > > socket. In
> > > any case, it does not seem right.
> >
> > Yes, it works. The ioctl is routed to per-socket functions.
> 
> Even if it works, sockets are probably not supposed to use the device-
> private
> ioctl() range, are they?
> 
> And why is this inside __KERNEL__ ?
Ok..We move it.

> > > Do you still need this read-only option?
> >
> > Yes.
> 
> Why and how?
This is needed for user to poll pipe-state.

Regards,
Hemant
