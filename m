From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net] net: bridge: fix returning of vlan range op errors
Date: Thu, 19 Oct 2017 15:22:19 -0700
Message-ID: <CAJieiUiM2FWA+7LomQTQjjCruFesoJo=cd2yGVg4s0XzGbxfHQ@mail.gmail.com>
References: <1508433452-23812-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        bridge@lists.linux-foundation.org,
        "stephen@networkplumber.org" <stephen@networkplumber.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f196.google.com ([209.85.217.196]:47009 "EHLO
        mail-ua0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754249AbdJSWWV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 18:22:21 -0400
Received: by mail-ua0-f196.google.com with SMTP id w45so7095629uac.3
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 15:22:20 -0700 (PDT)
In-Reply-To: <1508433452-23812-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 10:17 AM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> When vlan tunnels were introduced, vlan range errors got silently
> dropped and instead 0 was returned always. Restore the previous
> behaviour and return errors to user-space.
>
> Fixes: efa5356b0d97 ("bridge: per vlan dst_metadata netlink support")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---

Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

thanks
