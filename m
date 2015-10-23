From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute RFC PATCH 0/9] Document tc filters
Date: Fri, 23 Oct 2015 15:41:12 -0700
Message-ID: <20151023154112.7e57c730@xeon-e3>
References: <1445622436-6386-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:8175 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751301AbbJWWle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 18:41:34 -0400
In-Reply-To: <1445622436-6386-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 Oct 2015 19:47:07 +0200
Phil Sutter <phil@nwl.cc> wrote:

> This series adds documentation in form of a dedicated man page for every
> available tc filter with the exception of rsvp which I simply didn't
> understand. In addition to that, it adds a list of filters with (very) basic
> description to tc.8, listing the specific man pages for detailed information.
> 
> I am not too confident of correctness in every aspect, therefore this series is
> tagged RFC and the relevant patches are Cc'ed to the filter authors in hope for
> review and harsh criticism in form of corrections. :)
> 
> Alexey or anyone else with knowledge of rsvp, you could make me very happy by
> explaining to me how that filter is supposed to work. In turn I could serve you
> with stupid^Wunqualified questions and ultimately tc-rsvp.8 which you would
> then have to proof-read as well.
> 
> Phil Sutter (9):
>   tc: add a man page for basic filter
>   tc: add a man page for cgroup filter
>   tc: add a man page for flow filter
>   tc: add a man page for flower filter
>   tc: add a man page for fw filter
>   tc: add a man page for route filter
>   tc: add a man page for tcindex filter
>   tc: add a man page for u32 filter
>   tc: ship filter man pages and refer to them in tc.8
> 
>  man/man8/Makefile     |   4 +-
>  man/man8/tc-basic.8   |  34 +++
>  man/man8/tc-cgroup.8  |  80 ++++++
>  man/man8/tc-flow.8    | 265 ++++++++++++++++++++
>  man/man8/tc-flower.8  | 113 +++++++++
>  man/man8/tc-fw.8      |  66 +++++
>  man/man8/tc-route.8   |  74 ++++++
>  man/man8/tc-tcindex.8 |  58 +++++
>  man/man8/tc-u32.8     | 663 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  man/man8/tc.8         |  52 ++++
>  10 files changed, 1408 insertions(+), 1 deletion(-)
>  create mode 100644 man/man8/tc-basic.8
>  create mode 100644 man/man8/tc-cgroup.8
>  create mode 100644 man/man8/tc-flow.8
>  create mode 100644 man/man8/tc-flower.8
>  create mode 100644 man/man8/tc-fw.8
>  create mode 100644 man/man8/tc-route.8
>  create mode 100644 man/man8/tc-tcindex.8
>  create mode 100644 man/man8/tc-u32.8
> 

Looks good applied.
Had to one minor whitespace cleanup.
