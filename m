From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH RFC 0/2] kproxy: Kernel Proxy
Date: Thu, 29 Jun 2017 15:04:14 -0700
Message-ID: <CACby=pnLJRawb40Ym1_85+8P7vmkwLJqfsv=bYyeHHa8KWPwNA@mail.gmail.com>
References: <1498760825-8516-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36599 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751752AbdF2WEQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 18:04:16 -0400
Received: by mail-pf0-f175.google.com with SMTP id q86so56827411pfl.3
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 15:04:15 -0700 (PDT)
In-Reply-To: <1498760825-8516-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom

On 29 June 2017 at 11:27, Tom Herbert <tom@herbertland.com> wrote:
> This is raw, minimally tested, and error hanlding needs work. Posting
> as RFC to get feedback on the design...
>
> Sidecar proxies are becoming quite popular on server as a means to
> perform layer 7 processing on application data as it is sent. Such
> sidecars are used for SSL proxies, application firewalls, and L7
> load balancers. While these proxies provide nice functionality,
> their performance is obviously terrible since all the data needs
> to take an extra hop though userspace.

I really appreciate this work. It would have been nice to at least
attribute me in some way as this is exactly what I presented at
Netconf 2017 [0].

I'm also wondering why this is not built on top of KCM which you
suggested to use when we discussed this.

[0] https://docs.google.com/presentation/d/1dwSKSBGpUHD3WO5xxzZWj8awV_-xL-oYhvqQMOBhhtk/edit#slide=id.g203aae413f_0_0
