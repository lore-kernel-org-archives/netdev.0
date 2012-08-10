From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 7/8] bridge: add some comments for NETDEV_RELEASE
Date: Fri, 10 Aug 2012 04:13:18 -0700
Message-ID: <1344597198.2338.9.camel@joe2Laptop>
References: <1344263012-4031-1-git-send-email-amwang@redhat.com>
	 <1344263012-4031-8-git-send-email-amwang@redhat.com>
	 <20120806.135003.442648448779232464.davem@davemloft.net>
	 <1344296345.2026.3.camel@joe2Laptop>
	 <alpine.LNX.2.01.1208101257010.10147@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, amwang@redhat.com,
	netdev@vger.kernel.org, shemminger@vyatta.com
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:33179 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753133Ab2HJLNT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2012 07:13:19 -0400
In-Reply-To: <alpine.LNX.2.01.1208101257010.10147@frira.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-10 at 12:59 +0200, Jan Engelhardt wrote:
> On Tuesday 2012-08-07 01:39, Joe Perches wrote:
> >On Mon, 2012-08-06 at 13:50 -0700, David Miller wrote:
> >> > +	/*
> >> > +	 * We don't notify NETDEV_RELEASE event, as this will
> >> > +	 * stop netconsole on the bridge.
> >> > +	 */
> >> 
> >> Please format comments in the networking:
> >> 
> >> 	/* Like
> >> 	 * this.
> >> 	 */
> >
> >Maybe add a networking specific block comment style
> >to checkpatch. This doesn't trigger on files outside
> >of drivers/net and net.
> 
> Is there any particular reason why net/ wants to be special?

A determined maintainer with a strong desire
for consistency using an idiomatic style.

A thread about it:
https://lkml.org/lkml/2012/4/16/443
