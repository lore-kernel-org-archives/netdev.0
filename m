From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH 0/5] warning-annoyance induced code-review
Date: Sun, 29 Nov 2015 11:51:51 -0800
Message-ID: <20151129115151.637686fb@xeon-e3>
References: <1448668805-28074-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:26526 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752033AbbK2Tvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 14:51:48 -0500
In-Reply-To: <1448668805-28074-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 28 Nov 2015 01:00:00 +0100
Phil Sutter <phil@nwl.cc> wrote:

> The primary goal was to get rid of the -Wunused-result warnings emitted
> during compiling. While adding the necessary checks, I found a few
> functions which could benefit from a bigger review (patches 1, 2 and 3).
> Patch 4 then adds the remaining missing checks, and patch 5 simplifies
> fgets() usage at a few spots.
> 
> Note that the last patch is my first Coccinelle-generated change, which
> makes me especially proud. Many thanks again to Julia Lawall for her kind
> support via IRC at this point!
> 
> Phil Sutter (5):
>   lnstat: review lnstat_update()
>   ss: reduce max indentation level in init_service_resolver()
>   ss: review is_ephemeral()
>   get rid of remaining -Wunused-result warnings
>   get rid of unnecessary fgets() buffer size limitation
> 
>  misc/arpd.c        |   2 +-
>  misc/ifstat.c      |   6 ++-
>  misc/lnstat_util.c |  21 +++++------
>  misc/nstat.c       |   6 ++-
>  misc/ss.c          | 107 ++++++++++++++++++++++++++++-------------------------
>  5 files changed, 74 insertions(+), 68 deletions(-)
> 

Applied, thanks
