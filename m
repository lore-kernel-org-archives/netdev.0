From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch iproute2] u32: add terminal parameter
Date: Fri, 11 Apr 2014 17:45:53 -0700
Message-ID: <CAM_iQpVpNOJ1xiK45qXGRXgBZ2QcmwoPc7p=SOHCo=1kTwPfFQ@mail.gmail.com>
References: <1396631826-15188-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140411140446.6412e9dc@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:50265 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbaDLApy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 20:45:54 -0400
Received: by mail-ob0-f170.google.com with SMTP id uz6so6860091obc.15
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2014 17:45:54 -0700 (PDT)
In-Reply-To: <20140411140446.6412e9dc@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 11, 2014 at 2:04 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>
> Iproute2 commands are supposed to be invertible.
> If you take something as input, it should be displayed on output.

It's already there:

        } else if (sel && sel->flags&TC_U32_TERMINAL) {
                fprintf(f, "terminal flowid ??? ");
        }
