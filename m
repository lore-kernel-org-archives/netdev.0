From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next v2 1/2] net: Add skb_get_hash_noeval
Date: Tue, 14 Jan 2014 16:07:49 -0800
Message-ID: <CAHA+R7NXaZ=+4aUcSgO5bMnKUcXiqrNQSoumdkuGDmfr-RJqYw@mail.gmail.com>
References: <alpine.DEB.2.02.1401141556350.25158@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:35521 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbaAOAHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 19:07:50 -0500
Received: by mail-la0-f41.google.com with SMTP id mc6so887565lab.0
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 16:07:49 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1401141556350.25158@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 4:01 PM, Tom Herbert <therbert@google.com> wrote:
> Function to just return skb->rxhash without checking to see if it needs
> to be recomputed.
>

skb_get_hash_raw() is a better name.
