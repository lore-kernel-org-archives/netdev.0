From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/5] HFSC patches, part 1
Date: Fri, 01 Jul 2016 05:07:57 -0400 (EDT)
Message-ID: <20160701.050757.234421925335359788.davem@davemloft.net>
References: <1467246408-913-1-git-send-email-soltys@ziu.info>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: soltys@ziu.info
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37217 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752201AbcGAJRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 05:17:45 -0400
In-Reply-To: <1467246408-913-1-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Soltys <soltys@ziu.info>
Date: Thu, 30 Jun 2016 02:26:43 +0200

> It's revised version of part of the patches I submitted really, really long
> time ago (back then I asked Patrick to ignore them as I found some issues
> shortly after submitting).
> 
> Anyway this is the first set with very simple fixes/changes though some of them
> relatively subtle (I tried to do very exhaustive commit messages explaining what
> and why with those).
> 
> The patches are against net-next tree.
> 
> The second set will be heavier - or rather with more complex explanations, among those I have:
> 
> - a fix to subtle issue introduced in
>   http://permalink.gmane.org/gmane.linux.kernel.commits.2-4/8281
>   along with simplifying related stuff
> - update times to 96 bits (which allows to "just" use 32 bit shifts and
>   improves curve definition accuracy at more extreme low/high speeds)
> - add curve "merging" instead of just selecting in convex case (computations
>   mirror those from concave intersection)
> 
> But these are eventually for later.

Series applied, thanks.
