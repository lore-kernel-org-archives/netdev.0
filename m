From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] mpls: fix clearing of dead nh_flags on link up
Date: Wed, 31 May 2017 05:18:41 -0600
Message-ID: <af588b8f-28ad-dfe5-2262-1ed20ec53f91@gmail.com>
References: <1496213436-33961-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:36311 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750999AbdEaLSt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 07:18:49 -0400
Received: by mail-pg0-f42.google.com with SMTP id x64so6616009pgd.3
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 04:18:49 -0700 (PDT)
In-Reply-To: <1496213436-33961-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/31/17 12:50 AM, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> recent fixes to use WRITE_ONCE for nh_flags on link up,
> accidently ended up leaving the deadflags on a nh. This patch
> fixes the WRITE_ONCE to use freshly evaluated nh_flags.
> 
> Fixes: 39eb8cd17588 ("net: mpls: rt_nhn_alive and nh_flags should be accessed using READ_ONCE")
> Reported-by: Satish Ashok <sashok@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  net/mpls/af_mpls.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Acked-by: David Ahern <dsahern@gmail.com>
