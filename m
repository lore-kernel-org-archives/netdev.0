From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] b44: add 64 bit stats
Date: Sun, 15 Jul 2012 20:18:37 +0200
Message-ID: <1342376317.3265.11978.camel@edumazet-glaptop>
References: <CABF+-6XaYk8qXnFNXF_+rQ144jyDFgFqDVKsuZv+S_0VZxBAvw@mail.gmail.com>
	 <1342337165.3265.10640.camel@edumazet-glaptop>
	 <CABF+-6VZB=V1j2cAzhNkJozvcVs=VrQGYX_71HiZJ+g6od7qyA@mail.gmail.com>
	 <CABF+-6W0B0wB7hAfSRh83aEb_XPqaJuzA1nKZJygdd9xw-rN1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kevin Groeneveld <kgroeneveld@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:54952 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808Ab2GOSSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2012 14:18:43 -0400
Received: by eekb15 with SMTP id b15so1327065eek.19
        for <netdev@vger.kernel.org>; Sun, 15 Jul 2012 11:18:42 -0700 (PDT)
In-Reply-To: <CABF+-6W0B0wB7hAfSRh83aEb_XPqaJuzA1nKZJygdd9xw-rN1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-07-15 at 14:00 -0400, Kevin Groeneveld wrote:
> From: Kevin Groeneveld <kgroeneveld@gmail.com>
> 
> Add support for 64 bit stats to Broadcom b44 ethernet driver.
> 
> Signed-off-by: Kevin Groeneveld <kgroeneveld@gmail.com>
> ---
> v2: use u64_stats_fetch_begin_bh/u64_stats_fetch_retry_bh instead of
>     u64_stats_fetch_begin/u64_stats_fetch_retry as stats update happens in a
>     timer interrupt
> 
>  drivers/net/ethernet/broadcom/b44.c |   96 ++++++++++++++++++++---------------
>  drivers/net/ethernet/broadcom/b44.h |    3 +-
>  2 files changed, 58 insertions(+), 41 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
