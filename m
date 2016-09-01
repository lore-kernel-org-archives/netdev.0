From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2 v3 0/2] Add matchall support to tc
Date: Thu, 1 Sep 2016 08:39:37 -0700
Message-ID: <20160901083937.65db1e24@xeon-e3>
References: <1472628507-1991-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yotamg@mellanox.com, eladr@mellanox.com,
        idosch@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34023 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933290AbcIAPj0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 11:39:26 -0400
Received: by mail-pf0-f176.google.com with SMTP id p64so32530569pfb.1
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 08:39:26 -0700 (PDT)
In-Reply-To: <1472628507-1991-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 Aug 2016 09:28:25 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Yotam says:
> Add the matchall classifier support to tc and added the specific man pages.
> 
> ---
> v2->v3:
> -fixed couple of typos in man pages
> v1->v2:
> -fixed couple of checkpatch issues
> 
> Yotam Gigi (2):
>   tc: Add support for the matchall traffic classifier.
>   tc: man: Add man entry for the matchall classifier.
> 
>  man/man8/Makefile      |   2 +-
>  man/man8/tc-matchall.8 |  76 ++++++++++++++++++++++++++
>  man/man8/tc.8          |   5 ++
>  tc/Makefile            |   1 +
>  tc/f_matchall.c        | 143 +++++++++++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 226 insertions(+), 1 deletion(-)
>  create mode 100644 man/man8/tc-matchall.8
>  create mode 100644 tc/f_matchall.c
> 

Both applied to master
