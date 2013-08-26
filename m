From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: TSO packets automatic sizing
Date: Sun, 25 Aug 2013 17:37:05 -0700
Message-ID: <1377477425.8828.101.camel@edumazet-glaptop>
References: <1377304192.8828.43.camel@edumazet-glaptop>
	 <CADVnQymvQz67k1_f4rRJxPVUFWL=rM5vnT-ZO1VPSxN-E0uzDA@mail.gmail.com>
	 <1377370594.8828.72.camel@edumazet-glaptop>
	 <CAK6E8=f0S5SSr5vEN2L-J69aNPC78W9qbGT3Wp5z-65AGp+ZRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Van Jacobson <vanj@google.com>,
	Tom Herbert <therbert@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:64346 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754543Ab3HZAhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Aug 2013 20:37:07 -0400
Received: by mail-pb0-f49.google.com with SMTP id xb4so2755663pbc.22
        for <netdev@vger.kernel.org>; Sun, 25 Aug 2013 17:37:06 -0700 (PDT)
In-Reply-To: <CAK6E8=f0S5SSr5vEN2L-J69aNPC78W9qbGT3Wp5z-65AGp+ZRA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-08-25 at 15:01 -0700, Yuchung Cheng wrote:

> Any idea to get rid of this undesirable extra RTT delay?

Its probably a bug in the push code.
