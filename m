From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next RFC 5/5] net-timestamp: tx timestamping default
 mode flag
Date: Sun, 11 Jan 2015 20:49:00 -0500
Message-ID: <CA+FuTSfDVbSCGfJDjY3kv=SuGT221OuYAFVxDvRqouNcrJbvYw@mail.gmail.com>
References: <1420824719-28848-1-git-send-email-willemb@google.com>
 <1420824719-28848-6-git-send-email-willemb@google.com> <20150111203256.GC4214@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andy Lutomirski <luto@amacapital.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:46661 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724AbbALBtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2015 20:49:32 -0500
Received: by mail-qg0-f41.google.com with SMTP id e89so15864517qgf.0
        for <netdev@vger.kernel.org>; Sun, 11 Jan 2015 17:49:31 -0800 (PST)
In-Reply-To: <20150111203256.GC4214@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 11, 2015 at 3:32 PM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Fri, Jan 09, 2015 at 12:31:59PM -0500, Willem de Bruijn wrote:
>> From: Willem de Bruijn <willemb@google.com>
>>
>> The number of timestamping points along the transmit path has grown,
>> as have the options. Preferred behavior is to request timestamps with
>> ID, without data (which enables batching) and for all supported
>> timestamp points. Define a short option that enables all these
>> defaults.
>
> This "preferred behavior" is subjective, and it depends on the
> application.  I am sure it reflects your own interest, but for people
> doing PTP over UDP or raw, it is a bit misleading.
>
> I would drop this default and just let applications define their own.

Okay. I indeed hadn't considered that use-case.

Just so I understand: ptp has no use for the sw tstamps
that would be generated with this flag, but is otherwise
okay with enabling counters to order tx timestamps
(OPT_ID) and disabling payload (OPT_TSONLY)?

In the documentation, I would like to strongly suggest all
processes to enable these, even in absence of this default.
because that is more robust wrt the sysctl (if merged).

>
> Thanks,

Thanks for taking a look at the patches.

> Richard
