From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCHv4 iproute2 1/2] lib/libnetlink: re malloc buff if size is
 not enough
Date: Fri, 29 Sep 2017 14:55:07 +0200
Message-ID: <20170929125507.nkut3wtsvhq44evj@unicorn.suse.cz>
References: <1506605626-1744-1-git-send-email-haliu@redhat.com>
 <1506605626-1744-2-git-send-email-haliu@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Phil Sutter <phil@nwl.cc>, Hangbin Liu <liuhangbin@gmail.com>
To: Hangbin Liu <haliu@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42034 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750977AbdI2MzJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 08:55:09 -0400
Content-Disposition: inline
In-Reply-To: <1506605626-1744-2-git-send-email-haliu@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 28, 2017 at 09:33:45PM +0800, Hangbin Liu wrote:
> From: Hangbin Liu <liuhangbin@gmail.com>
> 
> With commit 72b365e8e0fd ("libnetlink: Double the dump buffer size")
> we doubled the buffer size to support more VFs. But the VFs number is
> increasing all the time. Some customers even use more than 200 VFs now.
> 
> We could not double it everytime when the buffer is not enough. Let's just
> not hard code the buffer size and malloc the correct number when running.
> 
> Introduce function rtnl_recvmsg() to always return a newly allocated buffer.
> The caller need to free it after using.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  lib/libnetlink.c | 114 ++++++++++++++++++++++++++++++++++++++-----------------
>  1 file changed, 80 insertions(+), 34 deletions(-)
> 

Reviewed-by: Michal Kubecek <mkubecek@suse.cz>
