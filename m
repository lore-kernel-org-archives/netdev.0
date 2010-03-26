From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [Patch] fix packet loss and massive ping spikes with PPP
 multi-link
Date: Fri, 26 Mar 2010 17:04:28 +0000
Message-ID: <20100326170428.6c1ad66c@lxorguk.ukuu.org.uk>
References: <2d460de71003260850x7f90d04cy79ac853464108182@mail.gmail.com>
	<20100326160226.0159ac3b@lxorguk.ukuu.org.uk>
	<4BACE827.4070006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Richard Hartmann <richih.mailinglist@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-ppp@vger.kernel.org
To: "Alexander E. Patrakov" <patrakov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:51900 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752082Ab0CZRAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 13:00:34 -0400
In-Reply-To: <4BACE827.4070006@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Mar 2010 22:00:23 +0500
"Alexander E. Patrakov" <patrakov@gmail.com> wrote:

> 26.03.2010 21:02, Alan Cox wrote:
> 
> > You can then do this
> >
> > static int ml_explode = 1;
> > module_param(ml_explode, int, 0600);
> > MODULE_PARM_DESC(ml_expode, "Set this to zero to disabling multilink \
> > 	fragmentation when talking to cisco devices");
> >
> > which will let you load the module with the option ml_explode = 0 if you
> > want that property.
> >
> > Making it runtime per link selectable would be nicer but thats a bit more
> > work.
> 
> Doesn't it work already via echoing values to 
> /sys/module/ppp/generic/parameters/ml_explode in the above code?

Thats runtime (and why I set 0600 in the permissions for the example) but
not per link.

Alan
