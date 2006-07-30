From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: Subsystem/prefix in patch submission format
Date: Mon, 31 Jul 2006 00:45:43 +0200
Message-ID: <20060730224543.GA9506@mars.ravnborg.org>
References: <Pine.LNX.4.58.0607301342150.19037@kivilampi-30.cs.helsinki.fi> <20060730.152846.42906358.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:2435 "EHLO pasmtp.tele.dk")
	by vger.kernel.org with ESMTP id S964772AbWG3Wpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2006 18:45:50 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060730.152846.42906358.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 30, 2006 at 03:28:46PM -0700, David Miller wrote:
> From: "Ilpo J?rvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Sun, 30 Jul 2006 14:01:09 +0300 (EEST)
> 
> >    [TCP] FRTO: summary here
> 
> This looks perfectly fine.
Looking 100 commits back or so it is obvious we have two distinct
notations:
	subsystem: <what was changed>
and
	[subsystem] <what was changed>

net related stuff counts for most of the latter but it is used in
several other places.

>From a pure eye-candy perspective it would be nice to use same format
all over.
>From Documentation/SubmittingPatches:
------------------
12) The canonical patch format

The canonical patch subject line is:

    Subject: [PATCH 001/123] subsystem: summary phrase
--------------

	Sam
