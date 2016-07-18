From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [iproute PATCH v5 1/5] tc: m_action: Improve conversion to C99
 style initializers
Date: Mon, 18 Jul 2016 10:09:07 -0600
Message-ID: <2078697f-5750-122a-7815-1208ba841160@cumulusnetworks.com>
References: <1468853325-9260-1-git-send-email-phil@nwl.cc>
 <1468853325-9260-2-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>, Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:37537 "EHLO
	mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441AbcGRQJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 12:09:33 -0400
Received: by mail-it0-f42.google.com with SMTP id f6so78260463ith.0
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 09:09:15 -0700 (PDT)
In-Reply-To: <1468853325-9260-2-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/18/16 8:48 AM, Phil Sutter wrote:
> This improves my initial change in the following points:
>
> - Flatten embedded struct's initializers.
> - No need to initialize variables to zero as the key feature of C99
>   initializers is to do this implicitly.
> - By relocating the declaration of struct rtattr *tail, it can be
>   initialized at the same time.
>
> Fixes: a0a73b298a579 ("tc: m_action: Use C99 style initializers for struct req")
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
> Changes since v2:
> - Don't drop the "superfluous" comma.
> - Flatten initializers.
> Changes since v1:
> - Created this patch.
> ---
>  tc/m_action.c | 23 +++++++----------------
>  1 file changed, 7 insertions(+), 16 deletions(-)
>

Acked-by: David Ahern <dsa@cumulusnetworks.com>
