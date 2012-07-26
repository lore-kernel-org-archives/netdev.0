From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute: Add route showdump command
Date: Thu, 26 Jul 2012 09:03:15 -0700
Message-ID: <20120726090315.4a566a46@nehalam.linuxnetplumber.net>
References: <50110593.1070502@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dan Smith <danms@us.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37002 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752212Ab2GZQDk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jul 2012 12:03:40 -0400
In-Reply-To: <50110593.1070502@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Jul 2012 12:53:39 +0400
Pavel Emelyanov <xemul@parallels.com> wrote:

> Some time ago the save+restore commands were added to ip route (git
> id f4ff11e3, Add ip route save/restore). These two save the raw rtnl
> stream into a file and restore one (reading it from stdin).
> 
> The problem is that there's no way to get the contents of the dump
> file in a human readable form. How about adding a command that reads
> the rtnl stream from stdin and prints the data in a way the usual
> "ip route list" does?
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Being able to decode a dump is great idea.
Are the user's smart enough not to try it out at the command prompt
and get totally lost? Maybe another isatty() check is needed.

Another solution would be to put a small header on the save file with
a magic number that could be checked. This would mean changing save/restore/showdump
and ideally updating the magic file in distributions.
