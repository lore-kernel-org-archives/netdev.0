From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23-rc[68]-mm: network hangs
Date: Sat, 29 Sep 2007 01:31:06 -0700
Message-ID: <20070929013106.4f84320d.akpm@linux-foundation.org>
References: <46FD5A82.9070505@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kernel development list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Laurent Riffard <laurent.riffard@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42035 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754542AbXI2IbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 04:31:11 -0400
In-Reply-To: <46FD5A82.9070505@free.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Sep 2007 21:48:18 +0200 Laurent Riffard <laurent.riffard@free.fr> wrote:

> Hi,
> 
> >From time to time, I experience some complete network hangs:
> 
> Suddenly, all network connections become unresponsive. Even "ping
> 127.0.0.1" doesn't work. SysRq-w does not show any blocked processus.
> 
> When such hang happen, I have to reboot (shutdown does work).
> 
> This is not easily reproducible: it happens several minutes after 
> boot (could be 45 minutes or 2 hours). I do not use heavy networking 
> apps (like P2P). My typical usage is a Gnome desktop with  browser, 
> mailer, IM, video or audio streaming. 
> 
> I have a single PC connected to a DSL router via ethernet (so no LAN 
> with NFS or CIFS).
> 
> This happens with 2.6.23-rc8-mm2 and 2.6.23-rc6-mm1. I can't remember 
> when I first see this problem. Maybe 2 months ago.
> 
> I attached the output of "strace ping 127.0.0.1". How can I collect 
> some more data when this problem happens ?
> 

I have a second report of this from Uwe Bugla (who has been banished from
all vger lists for various naughtinesses).

Similar story - after a few hours his network router (which is using ppp in
some fashion) craps out and dhcp queries all time out.

I'd be suspecting a ppp bug in net-2.6.24.
