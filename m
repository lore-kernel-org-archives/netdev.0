From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in tcp timestamp option ? TSecr in SYN-ACK != TSval in SYN
Date: Wed, 27 May 2015 11:02:12 -0700
Message-ID: <1432749732.4060.418.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CABK1yFBN7KgBxRRzx-Bmt86_L8PnbfgqNJr7Mc2o9usn=LKSTg@mail.gmail.com>
	 <1432707139.4060.351.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432707810.4060.352.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CABK1yFDJNonOr0O7N3gjJw-AripeaRqC1Xi+sDt7i_s0gC+ZLQ@mail.gmail.com>
	 <1432733597.4060.375.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432734319.4060.383.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CABK1yFDu+76vYJwwXf+0Kc3YBK6VHL224v_u=HTf-RZ7dGN6qQ@mail.gmail.com>
	 <1432749433.4060.416.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Van Jacobson <vanj@google.com>
To: Gopakumar Choorakkot Edakkunni <gopakumar.c.e@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:33772 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698AbbE0SCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 14:02:13 -0400
Received: by iebgx4 with SMTP id gx4so19834212ieb.0
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 11:02:13 -0700 (PDT)
In-Reply-To: <1432749433.4060.416.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-27 at 10:57 -0700, Eric Dumazet wrote:
> On Wed, 2015-05-27 at 10:29 -0700, Gopakumar Choorakkot Edakkunni wrote:
> > Thanks Eric. I will give this a spin. The issue doesnt happen all the
> > time, I can keep the server running with this patch for a while and
> > observe if the issue resurfaces or not
> 
> Note that if the traffic on the server is low, you might want to keep a
> tcpdump running (capturing only headers for TCP port 443) for further
> analysis.

We wonder if this could be a time-wait issue

Could you check on the server :

sysctl net.ipv4.tcp_tw_recycle
sysctl net.ipv4.tcp_tw_reuse

Thanks
