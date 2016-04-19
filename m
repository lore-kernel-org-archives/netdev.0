From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: take care of unknown min_rtt
Date: Tue, 19 Apr 2016 07:57:39 -0700
Message-ID: <20160419075739.57bfd9f7@xeon-e3>
References: <1460585918.10638.42.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36860 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932106AbcDSO50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 10:57:26 -0400
Received: by mail-pa0-f52.google.com with SMTP id er2so7428797pad.3
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 07:57:26 -0700 (PDT)
In-Reply-To: <1460585918.10638.42.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Apr 2016 15:18:38 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Kernel sets info->tcpi_min_rtt to ~0U when no RTT sample was ever
> taken for the session, thus min_rtt is unknown.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  misc/ss.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 


Applied
