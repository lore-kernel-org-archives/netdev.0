From: Patrick McHardy <kaber@trash.net>
Subject: Re: SFQ: Reordering?
Date: Sat, 07 May 2005 00:07:42 +0200
Message-ID: <427BEAAE.409@trash.net>
References: <7bca1cb5050506145344d16b1e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Asim Shankar <asimshankar@gmail.com>
In-Reply-To: <7bca1cb5050506145344d16b1e@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Asim Shankar wrote:
> Hi,
> 
> I was looking through sch_sfq.c. From what I could make out, if the
> perturbation period is non-zero (say Xseconds), then ever X seconds,
> sfq_perturbation() is invoked. This changes the perturbation value
> that will be used by the hash function, however, packets already
> existing in the queue aren't rehashed.
> 
> As a result, new packets being enqueued will have a different hash
> value and thus packet re-ordering will take place. I ran a quick test
> using netperf and tcpdump and seem to notice this re-ordering.
> 
> Should complete rehashing take place in sfq_perturbation(), or am I
> missing something? (I was looking at 2.6.9 and also took a cursory
> glance at 2.6.11 on lxr.linux.no)

I think we should rehash. Can you send a patch?

Regards
Patrick
