From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in tcp timestamp option ? TSecr in SYN-ACK != TSval in SYN
Date: Wed, 27 May 2015 10:57:13 -0700
Message-ID: <1432749433.4060.416.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CABK1yFBN7KgBxRRzx-Bmt86_L8PnbfgqNJr7Mc2o9usn=LKSTg@mail.gmail.com>
	 <1432707139.4060.351.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432707810.4060.352.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CABK1yFDJNonOr0O7N3gjJw-AripeaRqC1Xi+sDt7i_s0gC+ZLQ@mail.gmail.com>
	 <1432733597.4060.375.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432734319.4060.383.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CABK1yFDu+76vYJwwXf+0Kc3YBK6VHL224v_u=HTf-RZ7dGN6qQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Van Jacobson <vanj@google.com>
To: Gopakumar Choorakkot Edakkunni <gopakumar.c.e@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:35548 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752990AbbE0R5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 13:57:14 -0400
Received: by igbyr2 with SMTP id yr2so91908206igb.0
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 10:57:14 -0700 (PDT)
In-Reply-To: <CABK1yFDu+76vYJwwXf+0Kc3YBK6VHL224v_u=HTf-RZ7dGN6qQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-27 at 10:29 -0700, Gopakumar Choorakkot Edakkunni wrote:
> Thanks Eric. I will give this a spin. The issue doesnt happen all the
> time, I can keep the server running with this patch for a while and
> observe if the issue resurfaces or not

Note that if the traffic on the server is low, you might want to keep a
tcpdump running (capturing only headers for TCP port 443) for further
analysis.

Thanks !
