From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: oops in tcp_v4_rcv.
Date: Wed, 28 May 2003 22:50:20 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030529015020.GS12434@conectiva.com.br>
References: <3ED54DBC.4020203@colorfullife.com> <3ED55F4D.1070306@colorfullife.com> <20030528.184054.78710412.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: manfred@colorfullife.com, netdev@oss.sgi.com, akpm@digeo.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030528.184054.78710412.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Wed, May 28, 2003 at 06:40:54PM -0700, David S. Miller escreveu:
>    From: Manfred Spraul <manfred@colorfullife.com>
>    Date: Thu, 29 May 2003 03:15:57 +0200
> 
>    I think I understand now what causes the crash:
>    The tcp_ehash assumes that the entries are of the type 'struct inet_sock'.
>    But the actual entry is of the type tcp_tw_bucket. And 'sk->inet.daddr' 
>    is not shared between both structures.
> 
> Thanks for figuring this out.  Indeed, I had suspected the
> sock layout change Arnaldo did early in 2.5.x as the main
> possible suspect.
> 
> I'll try to fix this.

I'm as well looking at this, longstanding bug :-\

- Arnaldo
