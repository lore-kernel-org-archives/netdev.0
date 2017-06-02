From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH iproute2] iproute: extend route get to return matching fib
 route
Date: Thu, 1 Jun 2017 22:57:08 -0600
Message-ID: <4b695a0c-f7fb-28f4-e802-fe6f18b94b21@gmail.com>
References: <1496379208-30573-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
        stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36095 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750710AbdFBE5X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 00:57:23 -0400
Received: by mail-pf0-f195.google.com with SMTP id n23so11119641pfb.3
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 21:57:23 -0700 (PDT)
In-Reply-To: <1496379208-30573-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/1/17 10:53 PM, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> Uses newly introduced RTM_GETROUTE flag RTM_F_FIB_MATCH
> to return a matching fib route. Introduces 'fibmatch'
> keyword to ip route get.
...
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  include/linux/rtnetlink.h |  1 +
>  ip/iproute.c              |  9 ++++++++-
>  man/man8/ip-route.8.in    | 12 ++++++++++++
>  3 files changed, 21 insertions(+), 1 deletion(-)

LGTM

Acked-by: David Ahern <dsahern@gmail.com>
