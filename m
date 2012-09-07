From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] iproute: Add route showdump command (v2)
Date: Fri, 7 Sep 2012 09:14:38 -0700
Message-ID: <20120907091438.6a15a4f8@nehalam.linuxnetplumber.net>
References: <50121F4D.8090606@parallels.com>
	<50121FB0.6060200@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34060 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751402Ab2IGQPH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2012 12:15:07 -0400
In-Reply-To: <50121FB0.6060200@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Jul 2012 08:57:20 +0400
Pavel Emelyanov <xemul@parallels.com> wrote:

> Some time ago the save+restore commands were added to ip route (git
> id f4ff11e3, Add ip route save/restore). These two save the raw rtnl
> stream into a file and restore one (reading it from stdin).
> 
> The problem is that there's no way to get the contents of the dump
> file in a human readable form. The proposal is to add a command that
> reads the rtnl stream from stdin and prints the data in a way the 
> usual "ip route list" does?
> 
> changes since v1:
> 
> * Take the magic at the beginning of the dump file into account
> * Check for stdin (the dump is taken from) is not a tty
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Applied this and the magic number change.
