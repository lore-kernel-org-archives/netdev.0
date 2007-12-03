From: "Jon Smirl" <jonsmirl@gmail.com>
Subject: Re: [PATCH] Fix memory corruption in fec_mpc52xx
Date: Mon, 3 Dec 2007 17:51:26 -0500
Message-ID: <9e4733910712031451t7a5da582ved97b34806ac4a32@mail.gmail.com>
References: <1196721490.13978.185.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	"Domen Puncer" <domen.puncer@telargo.com>,
	"Grant Likely" <grant.likely@secretlab.ca>
To: "David Woodhouse" <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:54075 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbXLCWv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 17:51:26 -0500
Received: by wa-out-1112.google.com with SMTP id v27so5573242wah
        for <netdev@vger.kernel.org>; Mon, 03 Dec 2007 14:51:26 -0800 (PST)
In-Reply-To: <1196721490.13978.185.camel@pmac.infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/3/07, David Woodhouse <dwmw2@infradead.org> wrote:
> From: Jon Smirl <jonsmirl@gmail.com>
>
> The mpc5200 fec driver is corrupting memory. This patch fixes two bugs
> where the wrong skb was being referenced.

What does it take to get this patch into the kernel? I've been posting
it since Nov 9.
It is an obvious bug. I can't even boot one of my boxes without it.

-- 
Jon Smirl
jonsmirl@gmail.com
