From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: question about linux tcp request queue handling
Date: Sun, 06 Jul 2003 13:24:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F08858E.8000907@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: palbrecht@qwest.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> Linux (2.4.18) places incoming connection requests into the syn_recd state
> when the server's backlog queue is full.  I thought they were supposed to be
> discarded if the server's backlog is full, forcing the client to
> subsequently retransmit the request after it times out.  Why does linux put
> the server side into the syn_recd state when its backlog is full?

Do you have tcp_syncookies on? And are you exceeding
the len as configured by tcp_max_syn_backlog?

thanks,
Nivedita

[Please cc or post to netdev, like most networking folk,
  dont subscribe to lkml]
