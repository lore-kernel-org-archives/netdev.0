From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 0/2] ip rule: merger iprule_flush and add
 selector support
Date: Thu, 22 Sep 2016 16:43:08 -0700
Message-ID: <20160922164308.6743a2da@xeon-e3>
References: <1474525729-2845-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35367 "EHLO
        mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754349AbcIVXnA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 19:43:00 -0400
Received: by mail-pa0-f43.google.com with SMTP id oz2so33806772pac.2
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 16:42:58 -0700 (PDT)
In-Reply-To: <1474525729-2845-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Sep 2016 14:28:47 +0800
Hangbin Liu <liuhangbin@gmail.com> wrote:

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
> 

Fix Phil's man page comment and resubmit.
