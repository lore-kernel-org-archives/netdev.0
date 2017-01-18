From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip/xfrm: Fix deleteall when having many policies
 installed
Date: Wed, 18 Jan 2017 09:03:02 -0800
Message-ID: <20170118090302.6efd6cce@xeon-e3>
References: <d056322e-7c23-7e19-3bdb-4afa5f04e409@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <shemminger@osdl.org>
To: Alexander Heinlein <alexander.heinlein@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:35582 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751014AbdARRNE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 12:13:04 -0500
Received: by mail-pg0-f50.google.com with SMTP id 194so6027766pgd.2
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 09:12:15 -0800 (PST)
In-Reply-To: <d056322e-7c23-7e19-3bdb-4afa5f04e409@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Jan 2017 15:09:01 +0100
Alexander Heinlein <alexander.heinlein@secunet.com> wrote:

> Fix "Policy buffer overflow" error when trying to use deleteall with
> many policies installed.
> 
> Signed-off-by: Alexander Heinlein <alexander.heinlein@secunet.com>
> ---
>  ip/xfrm_policy.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
> index cc9c0f1..451b982 100644
> --- a/ip/xfrm_policy.c
> +++ b/ip/xfrm_policy.c
> @@ -732,10 +732,8 @@ static int xfrm_policy_keep(const struct
> sockaddr_nl *who,

Patch is not formatted properly because your mailer is line wrapping
