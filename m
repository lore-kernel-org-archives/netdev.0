From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 1/1] NET: ipv6, fix potential null dereference
Date: Sun, 10 Jan 2010 12:47:42 +0200
Message-ID: <20100110104742.GC4769@x200>
References: <20100110103528.GA4769@x200>
 <4B49AE41.5000206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:55612 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264Ab0AJKsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2010 05:48:19 -0500
Received: by fxm25 with SMTP id 25so113fxm.21
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2010 02:48:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4B49AE41.5000206@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 10, 2010 at 11:38:57AM +0100, Jiri Slaby wrote:
> On 01/10/2010 11:35 AM, Alexey Dobriyan wrote:
> >> Stanse found a potential null dereference
> > 
> > Nobody learns from Coverity, it seems. :^)
> 
> If it is known, why the test is still there?
> 
> I don't have access to the Coverity results anyway.

Well, when Coverity first exposed their database there were innumerable
"potential NULL dereference" defects and people fixed them by moving
stuff and most were bogus and there were flamewars and there were second
wave and so on...

Apparently "check all callers" is very hard to do programmatically.

> > snmp6_unregister_dev() always called with valid idev.

irda patch is not right too: calling tty->ops->hook with NULL tty is
impossible.
