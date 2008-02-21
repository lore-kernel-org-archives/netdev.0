From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Thu, 21 Feb 2008 02:08:18 -0800
Message-ID: <1203588498.20345.20.camel@brick>
References: <1203586467.20345.14.camel@brick>
	 <1203587699.17534.135.camel@johannes.berg>
	 <20080221.020343.190715910.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, joe@perches.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.242]:14144 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756207AbYBUKIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 05:08:04 -0500
Received: by hs-out-0708.google.com with SMTP id 54so2686855hsz.5
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2008 02:08:03 -0800 (PST)
In-Reply-To: <20080221.020343.190715910.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-02-21 at 02:03 -0800, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Thu, 21 Feb 2008 10:54:59 +0100
> 
> > It modifies the buffer, and I think it's more likely that the warning
> > was introduced by
>  ...
> >     [NET]: Elminate spurious print_mac() calls.
> 
> Right and that's what I just suggested in another reply.
> 
> Harvey how did you "narrow it down" to Joe's patch?  Did you really
> bisect to figure it out, or did you just guess?  You said "commit X
> introduced" and if you really didn't bisect it down to that
> such a claim is very misleading.

Sorry, that was misleading, it was a simple-minded git-log/git-blame
very short look, saw that line introduced here.

Really, that should have read:

Sparse warning introduced since -rc2:
..etc

Harvey's best guess is this commit...

I'll be more careful about this language going forward.

Cheers,

Harvey

