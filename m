From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: linux/if_bridge.h no longer self contained (again)
Date: Wed, 30 Jul 2014 16:20:07 -0700
Message-ID: <CAM_iQpV6EvvoYE17oi2XN0cbBkssQv0j=VXVR1-uCtMoJrSHwQ@mail.gmail.com>
References: <CAGVrzcamm6bgTc_-1OZGD0L4DqQd5RfoVYftZic3MDvD8YMjxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Gregory Fong <gregory.0xf0@gmail.com>, carlos@redhat.com,
	eblake@redhat.com, Kumar Gala <galak@codeaurora.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:40769 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527AbaG3XUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 19:20:08 -0400
Received: by mail-oa0-f53.google.com with SMTP id j17so1434295oag.26
        for <netdev@vger.kernel.org>; Wed, 30 Jul 2014 16:20:07 -0700 (PDT)
In-Reply-To: <CAGVrzcamm6bgTc_-1OZGD0L4DqQd5RfoVYftZic3MDvD8YMjxA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Jul 30, 2014 at 3:05 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>
> What would be the recommended ways to move forward?
>
> Should we keep a local change that includes netinet/in6.h and just
> hope it does not cause any re-definitions?
>

I think we should just #include <linux/in6.h> since the redefinition error
was already fixed.
