From: Tom Herbert <tom@herbertland.com>
Subject: Re: [Patch net-next v2 0/5] fou: some fixes and updates
Date: Fri, 10 Apr 2015 13:38:36 -0700
Message-ID: <CALx6S37WGT7p=ZMLc+ZOiXmvjQxaxG+k6yR2m2h9SEn5Av5xjg@mail.gmail.com>
References: <1428692430-14465-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:37469 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756220AbbDJUih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 16:38:37 -0400
Received: by igblo3 with SMTP id lo3so7442622igb.0
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 13:38:36 -0700 (PDT)
In-Reply-To: <1428692430-14465-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 10, 2015 at 12:00 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> Patch 1~3 fix some minor bugs in net/ipv4/fou.c, the only
> thing I am not sure is if it's too late to change the
> byte order of FOU_ATTR_PORT, if so we have to fix iproute2
> instead of kernel.
>
Is this a relic from previous patch set, or is there a reason you want
to make this hbo?

> Patch 4~5 add some new features to make it complete.
>
> v2: make fou->port be16 too
>
> Cong Wang (5):
>   fou: avoid calling udp_del_offload() twice
>   fou: exit early when parsing config fails
>   fou: always use be16 for port
>   fou: add network namespace support
>   fou: implement FOU_CMD_GET
>

I assume you didn't see any adverse performance impact with these patches?

Acked-by: Tom Herbert <tom@herbertland.com>

Thanks!
Tom

>  include/uapi/linux/fou.h |   1 +
>  net/ipv4/fou.c           | 230 +++++++++++++++++++++++++++++++++++++----------
>  2 files changed, 186 insertions(+), 45 deletions(-)
>
> --
> 1.8.3.1
>
