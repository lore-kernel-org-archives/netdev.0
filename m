From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] iproute: Add route showdump command (v2)
Date: Fri, 27 Jul 2012 10:05:57 -0700
Message-ID: <20120727100557.6c60ac58@nehalam.linuxnetplumber.net>
References: <50121F4D.8090606@parallels.com>
	<50121FB0.6060200@parallels.com>
	<5012211A.4040307@parallels.com>
	<50122FD7.2060701@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41684 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751081Ab2G0RGV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2012 13:06:21 -0400
In-Reply-To: <50122FD7.2060701@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Jul 2012 10:06:15 +0400
Pavel Emelyanov <xemul@parallels.com> wrote:

> I mean something like the below, just put the RTM_GETADDR stream into a
> file and push it back into the kernel as is. It worked for me in trivial
> cases, but is this approach correct generically?

It is supposed to always work to reverse netlink messages back to the kernel.
There a couple of caveats:
 1. Some fields like statistics are just ignored by the kernel and can never
    be reset.
 2. The feature isn't commonly used and it is always possible that it will
    expose a kernel bug.
