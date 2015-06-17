From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v2] ipv4: include NLM_F_APPEND flag in append
 route notifications
Date: Wed, 17 Jun 2015 11:30:22 -0700
Message-ID: <CAE4R7bBAWVKV4vtv7kJFS+MxzWMTHjxPJJ=h-+7kj8WSrZjn3Q@mail.gmail.com>
References: <1434564421-32047-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:33010 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752442AbbFQSan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 14:30:43 -0400
Received: by oiyy130 with SMTP id y130so23601342oiy.0
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 11:30:42 -0700 (PDT)
In-Reply-To: <1434564421-32047-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 17, 2015 at 11:07 AM, Roopa Prabhu
<roopa@cumulusnetworks.com> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This patch adds NLM_F_APPEND flag to struct nlmsg_hdr->nlmsg_flags
> in newroute notifications if the route add was an append.
> (This is similar to how NLM_F_REPLACE is already part of new
> route replace notifications today)
>
> This helps userspace determine if the route add operation was
> an append.
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
> v2: flip if condition around append and change |= to =
> (feedback from Alexander Duyck and Scott Feldman)

Is this a bug fix for net, or a new feature for net-next?  Regardless,

Acked-by: Scott Feldman <sfeldma@gmail.com>
