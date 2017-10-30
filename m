From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v2 net-next] net: display hw address of source machine
 during ipv6 DAD failure
Date: Mon, 30 Oct 2017 17:44:21 -0600
Message-ID: <fb6999ed-0b8d-c55d-b0fb-78b61d4b1f9a@gmail.com>
References: <1509406732-21855-1-git-send-email-vpai@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilubashe@akamai.com, pai.vishwain@gmail.com
To: Vishwanath Pai <vpai@akamai.com>, yoshfuji@linux-ipv6.org,
        kuznet@ms2.inr.ac.ru, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:46197 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751593AbdJ3XoX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 19:44:23 -0400
Received: by mail-pf0-f196.google.com with SMTP id p87so12283179pfj.3
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 16:44:23 -0700 (PDT)
In-Reply-To: <1509406732-21855-1-git-send-email-vpai@akamai.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/17 5:38 PM, Vishwanath Pai wrote:
> This patch updates the error messages displayed in kernel log to include
> hwaddress of the source machine that caused ipv6 duplicate address
> detection failures.
> 
> Examples:
> 
> a) When we receive a NA packet from another machine advertising our
> address:
> 
> ICMPv6: NA: 34:ab:cd:56:11:e8 advertised our address 2001:db8:: on eth0!
> 
> b) When we detect DAD failure during address assignment to an interface:
> 
> IPv6: eth0: IPv6 duplicate address 2001:db8:: used by 34:ab:cd:56:11:e8
> detected!
> 
> v2:
>     Changed %pI6 to %pI6c in ndisc_recv_na()
>     Chaged the v6 address in the commit message to 2001:db8::
> 
> Suggested-by: Igor Lubashev <ilubashe@akamai.com>
> Signed-off-by: Vishwanath Pai <vpai@akamai.com>
> ---
>  include/net/addrconf.h | 2 +-
>  net/ipv6/addrconf.c    | 6 +++---
>  net/ipv6/ndisc.c       | 9 +++++----
>  3 files changed, 9 insertions(+), 8 deletions(-)

LGTM

Acked-by: David Ahern <dsahern@gmail.com>
