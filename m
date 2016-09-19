From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v3 net-next 16/16] tcp_bbr: add BBR congestion control
Date: Sun, 18 Sep 2016 22:43:15 -0400
Message-ID: <CADVnQymXFoHHWkxKCxMabHFE6NetNO0hvdcqya0y75eyj9wKtg@mail.gmail.com>
References: <1474236233-28511-1-git-send-email-ncardwell@google.com>
 <1474236233-28511-17-git-send-email-ncardwell@google.com> <CA++eYdtWkMqT1zk_D00H1TciYb_4+aQ6-96YzG1n_h4LLk663g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>, Van Jacobson <vanj@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:33594 "EHLO
        mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755551AbcISCo3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 22:44:29 -0400
Received: by mail-oi0-f48.google.com with SMTP id r126so179298445oib.0
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 19:43:45 -0700 (PDT)
In-Reply-To: <CA++eYdtWkMqT1zk_D00H1TciYb_4+aQ6-96YzG1n_h4LLk663g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 18, 2016 at 9:18 PM, Kenneth Klette Jonassen
<kennetkl@ifi.uio.no> wrote:
>> +static u64 bbr_rate_kbps(struct sock *sk, u64 rate)
>> +{
>> +       return bbr_rate_bytes_per_sec(sk, rate, BBR_UNIT) * 8 / 1000;
>
>
> Consider div_u64() here to keep all builds happy. :-) This adds __udivdi3()
> with the nxp powerpc toolchains I'm using.
>
> (Or have the one caller use bbr_rate_bytes_per_sec() instead.)

Thanks, Kenneth. We will fix this in the next revision (we like your
suggested approach of just using bbr_rate_bytes_per_sec()).

cheers,
neal
