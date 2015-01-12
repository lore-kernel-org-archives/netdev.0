From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next RFC 5/5] net-timestamp: tx timestamping default
 mode flag
Date: Mon, 12 Jan 2015 09:26:14 +0100
Message-ID: <20150112082612.GA5348@netboy>
References: <1420824719-28848-1-git-send-email-willemb@google.com>
 <1420824719-28848-6-git-send-email-willemb@google.com>
 <20150111203256.GC4214@localhost.localdomain>
 <CA+FuTSfDVbSCGfJDjY3kv=SuGT221OuYAFVxDvRqouNcrJbvYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andy Lutomirski <luto@amacapital.net>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:51038 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281AbbALI0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 03:26:20 -0500
Received: by mail-we0-f179.google.com with SMTP id q59so17631015wes.10
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 00:26:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CA+FuTSfDVbSCGfJDjY3kv=SuGT221OuYAFVxDvRqouNcrJbvYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 11, 2015 at 08:49:00PM -0500, Willem de Bruijn wrote:
> Just so I understand: ptp has no use for the sw tstamps
> that would be generated with this flag, but is otherwise
> okay with enabling counters to order tx timestamps
> (OPT_ID) and disabling payload (OPT_TSONLY)?

Yes.

> In the documentation, I would like to strongly suggest all
> processes to enable these, even in absence of this default.
> because that is more robust wrt the sysctl (if merged).

Sounds good.

Thanks,
Richard
