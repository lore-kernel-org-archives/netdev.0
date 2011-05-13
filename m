From: Bart Van Assche <bvanassche@acm.org>
Subject: Re: [RFC 1/3] RDMA: Add netlink infrastructure
Date: Fri, 13 May 2011 20:12:06 +0200
Message-ID: <BANLkTi=P7u2XPx+_F9d9waP5xuXqDYb5yQ@mail.gmail.com>
References: <1305303525-11113-1-git-send-email-roland@kernel.org>
 <1305303525-11113-2-git-send-email-roland@kernel.org> <1305305065.8178.9.camel@Joe-Laptop>
 <BANLkTikpzn6R-QH__dtmwz=fO1QMUN+qag@mail.gmail.com> <1305308167.8178.20.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Roland Dreier <roland@kernel.org>, Nir Muchtar <nirm@voltaire.com>,
	netdev@vger.kernel.org, linux-rdma@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:60682 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754693Ab1EMSM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 14:12:27 -0400
In-Reply-To: <1305308167.8178.20.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 13, 2011 at 7:36 PM, Joe Perches <joe@perches.com> wrote:
> On Fri, 2011-05-13 at 19:18 +0200, Bart Van Assche wrote:
>> A recent dynamic debug patch made it possible to enable/disable at
>> runtime whether or not the function name (and more) should be included
>> in the output. See also http://lwn.net/Articles/434833/ for more
>> information.
>
> One long term goal for me is a generic run-time mechanism
> to prefix all pr_<level> uses not just the <foo>_dbg ones
> with or without module or function name.
>
> It will also allow the removal of all the uses of
> #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>
> New #define pr_fmt lines need to be added to the current
> files that use pr_<level> without a prefix so it could
> take awhile.

Something like the +m flag documented in
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=Documentation/dynamic-debug-howto.txt;hb=HEAD
?

Bart.
