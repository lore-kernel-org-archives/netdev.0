From: "David S. Miller" <davem@redhat.com>
Subject: Re: oops in tcp_v4_rcv.
Date: Wed, 28 May 2003 20:06:23 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030528.200623.28791498.davem@redhat.com>
References: <20030529015020.GS12434@conectiva.com.br>
	<20030528.185142.85410989.davem@redhat.com>
	<20030529020034.GT12434@conectiva.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, netdev@oss.sgi.com, akpm@digeo.com
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@conectiva.com.br
In-Reply-To: <20030529020034.GT12434@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
   Date: Wed, 28 May 2003 23:00:35 -0300

   Em Wed, May 28, 2003 at 06:51:42PM -0700, David S. Miller escreveu:
   > Here's a patch, should work:
   
   At first look, agreed. Thanks David for fixing this.

No problem.

And a big double-thanks for Mandred for tracking this down.
I wish him luck in tracking down the task struct use-after-free that
he's also seeing. :-)
