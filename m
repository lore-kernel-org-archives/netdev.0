From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Mon, 09 Jun 2003 10:21:31 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609.102131.73669235.davem@redhat.com>
References: <16091.11735.721251.925522@robur.slu.se>
	<20030602151852.GA6070@netnation.com>
	<16091.32021.75335.227150@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sim@netnation.com, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert.Olsson@data.slu.se
In-Reply-To: <16091.32021.75335.227150@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Robert Olsson <Robert.Olsson@data.slu.se>
   Date: Mon, 2 Jun 2003 18:36:37 +0200
   
   Simon Kirby writes:
   
    > Is it possible to have a dst LRU or a simpler approximation of such and
    > recycle dst entries rather than deallocating/reallocating them?  This
    > would relieve a lot of work from the garbage collector and avoid the
    > periodic large garbage collection latency.  It could be tuned to only
    > occur in an attack (I remember Alexey saying that the deferred garbage
    > collection was implemented to reduce latency in normal opreation).
   
    I don't see how this can be done. Others may?

Full recycle is very doable in 2.4.x, in 2.5.x is an enormously hard
problem because we use RCU there (readers run completely without
locks).
