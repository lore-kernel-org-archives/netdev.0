From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCHv2 iproute2 0/2] ip rule: merger iprule_flush and add
 selector support
Date: Fri, 23 Sep 2016 08:05:32 +0200
Message-ID: <20160923060532.GG31706@orbyte.nwl.cc>
References: <1474601155-28171-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:52596 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755979AbcIWGFf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 02:05:35 -0400
Content-Disposition: inline
In-Reply-To: <1474601155-28171-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 23, 2016 at 11:25:53AM +0800, Hangbin Liu wrote:
> When merge iprule_flush() and iprule_list_or_save(). Renamed
> rtnl_filter_t filter to filter_fn because we want to use global
> variable 'filter' to filter nlmsg in the next patch.
> 
> Hangbin Liu (2):
>   ip rule: merge ip rule flush and list, save together
>   ip rule: add selector support
> 
>  ip/iprule.c        | 295 +++++++++++++++++++++++++++++++++++++++++------------
>  man/man8/ip-rule.8 |   6 +-
>  2 files changed, 231 insertions(+), 70 deletions(-)

Acked-by: Phil Sutter <phil@nwl.cc>
