From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next 2/7] net-timestamp: MSG_TSTAMP one-shot tx timestamps
Date: Wed, 25 Jun 2014 17:20:58 -0400
Message-ID: <CA+FuTSfJo+zYzmvdECxm5d5isJjsYyBganT_2KLQF5Sq1Qj+tw@mail.gmail.com>
References: <1403624632-17327-1-git-send-email-willemb@google.com>
 <1403624632-17327-3-git-send-email-willemb@google.com> <20140625050158.GD3845@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f44.google.com ([209.85.216.44]:56660 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753932AbaFYVV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 17:21:29 -0400
Received: by mail-qa0-f44.google.com with SMTP id hw13so2048719qab.17
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 14:21:28 -0700 (PDT)
In-Reply-To: <20140625050158.GD3845@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 25, 2014 at 1:01 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Tue, Jun 24, 2014 at 11:43:47AM -0400, Willem de Bruijn wrote:
>> The kernel support datagram tx timestamping through socket option
>> SO_TIMESTAMPING. This patch add send() flag MSG_TSTAMP to allow
>> selectively requesting a timestamp for a single packet.
>
> This is a nice idea. I wonder whether the drivers will react
> correctly, need to think about it.
>
>> MSG_TSTAMP does not depend on SO_TIMESTAMPING. Enabling both
>> concurrently is redundant, but safe.
>>
>> This patch adds support for IPv4 and IPv6 UDP sendmsg().
>
> What about raw?

I saw that bug/feature request earlier this month, too. I can add that
as future work to this patch set. It seems like a straightforward
extension.

>
> Thanks,
> Richard
>
