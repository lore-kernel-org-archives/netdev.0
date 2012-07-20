From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 net-next] tcp: fix ABC in tcp_slow_start()
Date: Fri, 20 Jul 2012 09:50:36 -0700
Message-ID: <CADVnQymKnrN5Z=Pmzj3LvABS9A6SbqdWUKvjAtc5p833DO7PDQ@mail.gmail.com>
References: <1342796553.2626.7389.camel@edumazet-glaptop>
	<CAK6E8=dkwruGMtW2uQ--xZ_so9aZQt-KcmHsy2yE5GApKphrJQ@mail.gmail.com>
	<CADVnQy=nJz33pzd+o1WoCOR6Mk2pbB2x+bujqbfLUi8-+J=hGA@mail.gmail.com>
	<1342800536.2626.7670.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Yuchung Cheng <ycheng@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	John Heffner <johnwheffner@gmail.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:49975 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752498Ab2GTQuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 12:50:37 -0400
Received: by yhmm54 with SMTP id m54so4178617yhm.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 09:50:37 -0700 (PDT)
In-Reply-To: <1342800536.2626.7670.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 20, 2012 at 9:08 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> So to address your point, maybe we should clear  snd_cwnd_cnt
> when leaving slow start for congestion avoidance phase ?

Sounds good. That can be a separate commit to add the new logic to the
end of tcp_slow_start() to check to see if we've bumped into ssthresh
and reset snd_cwnd_cnt.

neal
