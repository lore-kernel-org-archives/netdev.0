From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip: neigh: Fix leftover attributes message
 during flush
Date: Tue, 19 Apr 2016 07:59:21 -0700
Message-ID: <20160419075921.073cf18e@xeon-e3>
References: <1460657703-8222-1-git-send-email-jefftharris@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Harris <jefftharris@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34133 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754742AbcDSO7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 10:59:50 -0400
Received: by mail-pa0-f51.google.com with SMTP id r5so6789577pag.1
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 07:59:44 -0700 (PDT)
In-Reply-To: <1460657703-8222-1-git-send-email-jefftharris@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Apr 2016 14:15:03 -0400
Jeff Harris <jefftharris@gmail.com> wrote:

> Use the same rtnl_dump_request_n call as the show.  The rtnl_wilddump_request
> assumes the type uses an ifinfomsg which is not the case for the neighbor
> table.
> 
> Signed-off-by: Jeff Harris <jefftharris@gmail.com>
> ---
>  ip/ipneigh.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)

Applied thanks
