From: Xufeng Zhang <xufengzhang.main@gmail.com>
Subject: Re: Question about esp sequence number and anti-reply window logic
Date: Tue, 3 Jun 2014 11:09:12 +0800
Message-ID: <CA+=dFzjWTBkZgKGzcCera4GCEXcTPZ84Zx9zL8TZbig9OVWxMA@mail.gmail.com>
References: <CA+=dFzhDVqRvFU0f8QoP7thV7LJeHN_375oe=dG=NoqoSGD1eQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f41.google.com ([209.85.216.41]:34037 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752323AbaFCDJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 23:09:13 -0400
Received: by mail-qa0-f41.google.com with SMTP id dc16so4089742qab.0
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 20:09:12 -0700 (PDT)
In-Reply-To: <CA+=dFzhDVqRvFU0f8QoP7thV7LJeHN_375oe=dG=NoqoSGD1eQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen,

Do you have an idea about why xfrm don't comply with the below RFC
specification?
is this a bug or something?


Thanks,
Xufeng

On 5/28/14, Xufeng Zhang <xufengzhang.main@gmail.com> wrote:
> Hi All,
>
> Per RFC4303:
> The sender assumes anti-replay is enabled as a default, unless
> otherwise notified by the receiver (see Section 3.4.3). Thus,
> typical behavior of an ESP implementation calls for the sender to
> establish a new SA when the Sequence Number (or ESN) cycles, or in
> anticipation of this value cycling.
>
> But currently the xfrm implementation don't establish a new SA when
> the Sequence Number cycles, it just give a notification to user.
> I know this might be a well-known limitation, but is there any document
> declare this about why xfrm didn't implement this?
>
> I also found a similar bug opened for this issue but without any response:
> https://bugzilla.kernel.org/show_bug.cgi?id=76791
>
>
> Thanks a lot!
> Xufeng
>
