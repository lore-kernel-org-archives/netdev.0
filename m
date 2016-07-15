From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [iproute PATCH v4 1/5] tc: m_action: Improve conversion to C99
 style initializers
Date: Fri, 15 Jul 2016 09:32:41 -0600
Message-ID: <228202dc-508f-2dd5-136f-bf04b271235c@cumulusnetworks.com>
References: <1468435639-6892-1-git-send-email-phil@nwl.cc>
 <1468435639-6892-2-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>, Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:38076 "EHLO
	mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298AbcGOPcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 11:32:43 -0400
Received: by mail-it0-f43.google.com with SMTP id h190so22274373ith.1
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 08:32:43 -0700 (PDT)
In-Reply-To: <1468435639-6892-2-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/13/16 12:47 PM, Phil Sutter wrote:
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

Acked-by: David Ahern <dsa@cumulusnetworks.com>
