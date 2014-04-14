From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch iproute2] u32: add terminal parameter
Date: Mon, 14 Apr 2014 14:18:58 -0700
Message-ID: <CAM_iQpXJnOOUbpS0WwrB7C50LGxcLhMEQPrDB84Zm-SLKVHh6w@mail.gmail.com>
References: <1396631826-15188-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140411140446.6412e9dc@nehalam.linuxnetplumber.net>
	<CAM_iQpVpNOJ1xiK45qXGRXgBZ2QcmwoPc7p=SOHCo=1kTwPfFQ@mail.gmail.com>
	<20140411175800.08e9ffe3@nehalam.linuxnetplumber.net>
	<CAM_iQpU7Ntn-yo-ez0vP2BhKe+-Vaq1w_+MQhFPHM-bbQZx2gg@mail.gmail.com>
	<534926F7.10505@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:44404 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754706AbaDNVS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 17:18:58 -0400
Received: by mail-ob0-f169.google.com with SMTP id va2so9754690obc.14
        for <netdev@vger.kernel.org>; Mon, 14 Apr 2014 14:18:58 -0700 (PDT)
In-Reply-To: <534926F7.10505@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 12, 2014 at 4:43 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> Cong,
>
> You MUST specify flowid in your filter construct;->

Why? The qdisc my u32 filters attached to is classless (ingress).

Also, why this is relevant to u32 terminal?

> So I agree with Stephen on the verdict on your patch.
> We need a patch to avoid this FAQ problem since it happens
> often i.e reject a filter that doesnt have flow/classid
> specified. How about you provide that patch instead?
>

Even if you were right, it is too late to change, we obviously don't
want to break existing scripts that work fine. I am pretty sure
my script runs well without flowid.
