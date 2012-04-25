From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] unix_diag: use netlink attribute MAX convention
Date: Wed, 25 Apr 2012 11:56:09 -0700
Message-ID: <20120425115609.4ef9ece0@nehalam.linuxnetplumber.net>
References: <4F97A484.2040300@gmail.com>
	<20120425092645.180ac196@nehalam.linuxnetplumber.net>
	<20120425103858.04d149d8@nehalam.linuxnetplumber.net>
	<20120425.141658.1934757959636497552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shanwei88@gmail.com, xemul@parallels.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33463 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757541Ab2DYS4N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 14:56:13 -0400
In-Reply-To: <20120425.141658.1934757959636497552.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Apr 2012 14:16:58 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 25 Apr 2012 10:38:58 -0700
> 
> > Use the standard convention to define the number of elements
> > in unix diag attribute. This fixes future problems like the fact
> > the last element (MEMINFO) is not parsed by current iproute2 ss command.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> You can't change this, it's already out in the wild, and
> for 2 releases.
> 
> Sorry.
> 
> Just accept the 'ss' patch that was posted and you objected to,
> I'm not breaking userspace just so that you don't have to apply
> a userland patch you perceive as an unacceptable quirk.

It only changes a broken enum value used only by iproute2.
Do you expect the one utility to use it to have a workaround for
a broken initial version.
