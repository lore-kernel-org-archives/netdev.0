From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [IPROUTE 00/03]: Increase number of possible routing tables
Date: Thu, 10 Aug 2006 16:13:20 -0700
Message-ID: <20060810161320.168674c8@localhost.localdomain>
References: <20060810221447.9060.5563.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:55779 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932250AbWHJXNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 19:13:25 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <20060810221447.9060.5563.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 11 Aug 2006 00:14:47 +0200 (MEST)
Patrick McHardy <kaber@trash.net> wrote:

> These patches add support for a larger number of routing tables to iproute
> and are needed for the patches doing the same for the kernel I just sent.
> They apply on top of the "[IPROUTE]: Support IPv6 routing table filter" patch.
> 
> Please apply, thanks.
> 
> 
>  include/linux/rtnetlink.h |    4 -
>  include/rt_names.h        |    2 
>  ip/ip_common.h            |    8 +++
>  ip/iproute.c              |   63 ++++++++++++++++------------
>  ip/iprule.c               |   14 +++++-
>  lib/rt_names.c            |  100 ++++++++++++++++++++++++++++++++++------------
>  6 files changed, 133 insertions(+), 58 deletions(-)
> 
> Patrick McHardy:
>       [IPROUTE]: Preparation for 32 bit table IDs
>       [IPROUTE]: Use hash for routing table name cache
>       [IPROUTE]: Add support for larger number of routing tables

Applied thanks. Let me know when your done, it has been too long
since a real release of iproute2. I'll roll one as soon as the flow subsides.
