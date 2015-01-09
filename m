From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH next] net: e1000e: support txtd update delay via xmit_more
Date: Thu, 8 Jan 2015 17:22:43 -0800
Message-ID: <CAL3LdT6F0Z2bEEQS-RjU1v=Xhb0N+oAi_n4k71aD0KK3p2KmvQ@mail.gmail.com>
References: <1420624162-24206-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:60580 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023AbbAIBWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 20:22:43 -0500
Received: by mail-oi0-f50.google.com with SMTP id x69so9991413oia.9
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 17:22:43 -0800 (PST)
In-Reply-To: <1420624162-24206-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 7, 2015 at 1:49 AM, Florian Westphal <fw@strlen.de> wrote:
> Don't update tx tail descriptor if queue hasn't been stopped
> and we know at least one more skb will be sent right away.
>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 23 +++++++++++++----------
>  1 file changed, 13 insertions(+), 10 deletions(-)
>

Thanks Florian, I will add your patch to my queue.
