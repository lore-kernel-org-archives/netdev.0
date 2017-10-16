From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2 0/4] Fix ip segfault when using --color
 switch
Date: Mon, 16 Oct 2017 09:24:59 -0700
Message-ID: <20171016092459.298da600@xeon-e3>
References: <20171013135719.18450-1-petr.vorel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Julien Fortin <julien@cumulusnetworks.com>
To: Petr Vorel <petr.vorel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:48952 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752996AbdJPQZC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 12:25:02 -0400
Received: by mail-pg0-f50.google.com with SMTP id v78so7200447pgb.5
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 09:25:02 -0700 (PDT)
In-Reply-To: <20171013135719.18450-1-petr.vorel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Oct 2017 15:57:15 +0200
Petr Vorel <petr.vorel@gmail.com> wrote:

> Hi Stephen,
> 
> I cleanup code not to use magic offsets. I kept it in separate commits,
> as it's clearer what happened.
> 
> Petr Vorel (4):
>   color: Fix ip segfault when using --color switch
>   color: Fix another ip segfault when using --color switch
>   color: Cleanup code to remove "magic" offset + 7
>   color: Rename enum
> 
>  include/color.h      |  3 +--
>  include/json_print.h |  2 +-
>  lib/color.c          | 17 ++++++++++-------
>  3 files changed, 12 insertions(+), 10 deletions(-)
> 

Applied, Thans Petr
