From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH next] net: e1000: support txtd update delay via xmit_more
Date: Tue, 6 Jan 2015 19:34:14 -0800
Message-ID: <CAL3LdT7P0RB12Wi1X=gcLs2xKQFQU9=AthhzHpon7160tViyVA@mail.gmail.com>
References: <1420557419-18869-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:38017 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754619AbbAGDeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 22:34:15 -0500
Received: by mail-ob0-f179.google.com with SMTP id va2so1339344obc.10
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 19:34:14 -0800 (PST)
In-Reply-To: <1420557419-18869-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 6, 2015 at 7:16 AM, Florian Westphal <fw@strlen.de> wrote:
> Don't update tx tail descriptor if we queue hasn't been stopped and
> we know at least one more skb will be sent right away.
>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c | 14 ++++++++------
>  1 file changed, 8 insertions(+), 6 deletions(-)

Thanks Florian, I will add your patch to my queue.
