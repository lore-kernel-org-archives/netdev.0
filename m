From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ath10k: wmi: Convert use of 6 to ETH_ALEN
Date: Wed, 02 Oct 2013 22:24:44 -0700
Message-ID: <1380777884.19002.155.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380679480.2081.24.camel@joe-AO722>
	 <87k3hw469z.fsf@kamboji.qca.qualcomm.com>
	 <1380696054.2081.35.camel@joe-AO722>
	 <CAB=NE6V3b4+B06hzPjhww52wp1FHho3329cP25=5Cy833bysvg@mail.gmail.com>
	 <1380736969.2081.72.camel@joe-AO722>
	 <alpine.DEB.2.02.1310030034030.2162@localhost6.localdomain6>
	 <1380758954.2081.79.camel@joe-AO722> <1380760114.2081.81.camel@joe-AO722>
	 <1380771110.2081.89.camel@joe-AO722> <1380771551.2081.93.camel@joe-AO722>
	 <1380773924.19002.131.camel@edumazet-glaptop.roam.corp.google.com>
	 <87fvsjynuk.fsf@kamboji.qca.qualcomm.com>
	 <1380775478.19002.139.camel@edumazet-glaptop.roam.corp.google.com>
	 <1380776994.2081.101.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@qca.qualcomm.com>,
	Julia Lawall <julia.lawall@lip6.fr>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	netdev <netdev@vger.kernel.org>, ath10k@lists.infradead.org,
	"John W. Linville" <linville@tuxdriver.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:43797 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757795Ab3JCFYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 01:24:46 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so1923836pbc.35
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 22:24:46 -0700 (PDT)
In-Reply-To: <1380776994.2081.101.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-02 at 22:09 -0700, Joe Perches wrote:
> On Wed, 2013-10-02 at 21:44 -0700, Eric Dumazet wrote:
> > I mean the 6, of course, since Joe seems to actively track them, as if
> > ETH_ALEN could change eventually, you never know.
> 
> You're funny Eric.
> You know it's just to ease grep pattern matching.

You are not funny if you plan to send 500+ patches for every instance of
6 changed to ETH_ALEN

I am not interested playing these grep games, honestly.

If you patch a driver, try to avoid sending one patch per line, that's
really not necessary, thank you.

If the structure definition uses [6], I see no reason to use ETH_ALEN in
the memset()/memcpy().

How is that funny, I don't know.
