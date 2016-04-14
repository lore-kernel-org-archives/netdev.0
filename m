From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 0/2] fix two more udp pull header issues
Date: Wed, 13 Apr 2016 22:57:33 -0400
Message-ID: <CAF=yD-JQeHCNQAeoDPB8p5WkMDKt+5+WB3zh73PPYxTSaab2_A@mail.gmail.com>
References: <1460067179-67789-1-git-send-email-willemdebruijn.kernel@gmail.com>
 <20160413.222554.1942915187151383805.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>,
	Sam Kumar <samanthakumar@google.com>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35890 "EHLO
	mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbcDNC6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 22:58:15 -0400
Received: by mail-lf0-f68.google.com with SMTP id p81so10035999lfb.3
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 19:58:14 -0700 (PDT)
In-Reply-To: <20160413.222554.1942915187151383805.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 13, 2016 at 10:25 PM, David Miller <davem@davemloft.net> wrote:
> From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
> Date: Thu,  7 Apr 2016 18:12:57 -0400
>
>> Follow up patches to the fixes to RxRPC and SunRPC. A scan of the
>> code showed two other interfaces that expect UDP packets to have
>> a udphdr when queued: read packet length with ioctl SIOCINQ and
>> receive payload checksum with socket option IP_CHECKSUM.
>
> As we are seeing, lots of places depend upon the old way of queueing
> up UDP frames. :-/

Yes, I greatly underestimated that. I should have done a much more
thorough scan before submitting. Hopefully we've caught them all now.

> Applied, thanks for mopping all of this up.

Apologies for breaking it in the first place!
