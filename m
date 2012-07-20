From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 net-next] tcp: fix ABC in tcp_slow_start()
Date: Fri, 20 Jul 2012 10:58:27 -0700
Message-ID: <CADVnQymoWQmdtTEv_KOvHbQvC6oC0EsJvhda5oAf7CVithS3Pg@mail.gmail.com>
References: <1342796553.2626.7389.camel@edumazet-glaptop>
	<CAK6E8=dkwruGMtW2uQ--xZ_so9aZQt-KcmHsy2yE5GApKphrJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	John Heffner <johnwheffner@gmail.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:34933 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805Ab2GTR62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 13:58:28 -0400
Received: by ghrr11 with SMTP id r11so4259378ghr.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 10:58:27 -0700 (PDT)
In-Reply-To: <CAK6E8=dkwruGMtW2uQ--xZ_so9aZQt-KcmHsy2yE5GApKphrJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 20, 2012 at 8:07 AM, Yuchung Cheng <ycheng@google.com> wrote:
> On Fri, Jul 20, 2012 at 8:02 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> When/if sysctl_tcp_abc > 1, we expect to increase cwnd by 2 if the
>> received ACK acknowledges more than 2*MSS bytes, in tcp_slow_start()
>>
>> Problem is this RFC 3465 statement is not correctly coded, as
>> the while () loop increases snd_cwnd one by one.
>>
>> Add a new variable to avoid this off-by one error.
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
