From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [bisected] Weird sysctl regression
Date: Sat, 23 Aug 2008 18:02:48 +0100
Message-ID: <20080823170248.GL28946@ZenIV.linux.org.uk>
References: <87fxoyal9j.fsf@natisbad.org> <20080823084936.GK28946@ZenIV.linux.org.uk> <87wsi7en1m.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:45512 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715AbYHWRCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 13:02:49 -0400
Content-Disposition: inline
In-Reply-To: <87wsi7en1m.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 23, 2008 at 06:03:33PM +0200, Arnaud Ebalard wrote:
> > Can you reproduce it on mainline kernel
> 
> All Linux 2.6.26 (initial and stable releases) are not affected. I am
> currently running 2.6.26.3.
> 
> > or bisect between the mainline and net-2.6 if mainline is OK?
> 
> As I wrote in my previous email, bisecting net-2.6 lead me to 
> 9043476f726802f4b00c96d0c4f418dde48d1304 ([PATCH] sanitize proc_sysctl)
> which is in the middle of a set of fs/sysctl related patches. 
> 
> I think I am missing the point on what you want me to do. Can you
> clarify? 

Check the tip of Linus' git tree.  Or, at least, something like -rc4.
