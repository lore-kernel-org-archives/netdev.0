From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [IPROUTE]: Fix up "ip link" help text
Date: Mon, 13 Oct 2008 11:07:46 -0700
Message-ID: <20081013110746.563d1226@extreme>
References: <48EB7D76.7050004@trash.net>
	<48EBCE59.3080401@trash.net>
	<20081013072129.2564130f@extreme>
	<200810131917.00864.arekm@maven.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Arkadiusz Miskiewicz <arekm@maven.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48327 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756662AbYJMSHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2008 14:07:49 -0400
In-Reply-To: <200810131917.00864.arekm@maven.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Oct 2008 19:17:00 +0200
Arkadiusz Miskiewicz <arekm@maven.pl> wrote:

> On Monday 13 of October 2008, Stephen Hemminger wrote:
> > On Tue, 07 Oct 2008 23:02:17 +0200
> >
> > Patrick McHardy <kaber@trash.net> wrote:
> > > Arkadiusz Miskiewicz wrote:
> > > > Runtime dependand help doesn't look sane. Help should always show all
> > > > possible options/command while trying to use unsupported option should
> > > > display error message.
> > >
> > > That makes sense. But don't complain to me about the quality
> > > of the error messages afterwards please :)
> >
> > I applied a variant of Patrick's original patch. I added text for delete,
> > and avoided some code movement.  The help text should only show what is
> > supported otherwise there will be user complaints.
> 
> Too bad. 
> 
> Help should show all options while trying to use unsupported ones should 
> yeld "unsupported"/some error message.
> 
> Will ipv6 options etc, etc also be hidden when ipv6 not available?
> 


The options won't show on older kernels. It is not a kernel config option
difference, it is old legacy code, like back to 2.4 where the API's just
aren't there.
