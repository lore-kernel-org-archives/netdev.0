From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 0/2] iputils: minor ninfod and ping6 fixes
Date: Thu, 20 Dec 2012 06:05:35 +0900
Message-ID: <50D22C1F.8010509@linux-ipv6.org>
References: <1354868724-15549-1-git-send-email-jsynacek@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jan Synacek <jsynacek@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:58745 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750798Ab2LSVFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 16:05:37 -0500
In-Reply-To: <1354868724-15549-1-git-send-email-jsynacek@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Synacek wrote:

> When calling ping6 with the flowlabel (e.g. `ping6 -F 123 ::1'), it exited with
> an error. For some reason, the errno was set when it should not have been. Maybe
> it shouldn't be checked at all, maybe just checking flowlabel for values below
> zero would be enough. I wanted to be on the safer side so I left the errno check
> in there.
> 
> Also, I fixed the rest of the unused variables in ninfod.
> 
> Jan Synacek (2):
>   ninfod: Fix more unused variables.
>   ping6: Fix -F switch.
> 
>  ninfod/ni_ifaddrs.c | 8 +-------
>  ping6.c             | 3 ++-
>  2 files changed, 3 insertions(+), 8 deletions(-)
> 

Fixes committed. Thank you!

--yoshfuji
