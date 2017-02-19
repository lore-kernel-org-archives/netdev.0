From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 0/4] ip vrf: updates to handle cgroup hiearchy
 and namespace nesting
Date: Sat, 18 Feb 2017 16:11:53 -0800
Message-ID: <20170218161153.7aed0a23@xeon-e3>
References: <1487264338-17588-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, luto@amacapital.net
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:34807 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750905AbdBSAL4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 19:11:56 -0500
Received: by mail-pg0-f48.google.com with SMTP id z67so25445108pgb.1
        for <netdev@vger.kernel.org>; Sat, 18 Feb 2017 16:11:56 -0800 (PST)
In-Reply-To: <1487264338-17588-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Feb 2017 08:58:54 -0800
David Ahern <dsa@cumulusnetworks.com> wrote:

> More updates to ip vrf for 4.10. Major changes: handle vrf in an existing
> cgroup hierarchy and handle vrf nesting in network namespaces.
> 
> Comparison of the netns in bpf code will be added once the kernel patch
> is accepted.
> 
> David Ahern (4):
>   ip vrf: Handle vrf in a cgroup hierarchy
>   ip netns: refactor netns_identify
>   ip vrf: Handle VRF nesting in namespace
>   ip vrf: Detect invalid vrf name in pids command
> 
>  ip/ip_common.h |   1 +
>  ip/ipnetns.c   |  47 +++++++-----
>  ip/ipvrf.c     | 222 ++++++++++++++++++++++++++++++++++++++++++++++++++-------
>  3 files changed, 227 insertions(+), 43 deletions(-)
> 

Applied all four thanks
