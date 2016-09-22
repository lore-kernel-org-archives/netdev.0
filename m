From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH iproute2 2/2] ip rule: add selector support
Date: Thu, 22 Sep 2016 10:45:53 +0200
Message-ID: <20160922084553.GA22100@orbyte.nwl.cc>
References: <1474525729-2845-1-git-send-email-liuhangbin@gmail.com>
 <1474525729-2845-3-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:46146 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933083AbcIVIpz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Sep 2016 04:45:55 -0400
Content-Disposition: inline
In-Reply-To: <1474525729-2845-3-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 22, 2016 at 02:28:49PM +0800, Hangbin Liu wrote:
[...]
> diff --git a/man/man8/ip-rule.8 b/man/man8/ip-rule.8
> index 3508d80..ec0e31d 100644
> --- a/man/man8/ip-rule.8
> +++ b/man/man8/ip-rule.8
> @@ -15,7 +15,8 @@ ip-rule \- routing policy database management
>  
>  .ti -8
>  .B  ip rule
> -.RB "[ " list " ]"
> +.RB "[ " list
> +.I "[ " SELECTOR " ]]"

This makes the brackets cursive, too. Better use this instead:

| .RI "[ " SELECTOR " ]]"

Apart from that, LGTM!

Thanks, Phil
