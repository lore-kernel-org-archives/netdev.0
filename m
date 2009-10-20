From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: kernel panic in latest vanilla stable, while using nameif with  "alive" pppoe interfaces
Date: Tue, 20 Oct 2009 14:52:58 +0300
Message-ID: <200910201452.58789.denys@visp.net.lb>
References: <200910190002.39937.denys@visp.net.lb> <200910201436.50249.denys@visp.net.lb> <aa79d98a0910200450n1a283f87hf946bb3b756d0bd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Michal Ostrowski <mostrows@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, linux-ppp@vger.kernel.org,
	paulus@samba.org, mostrows@earthlink.net
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <aa79d98a0910200450n1a283f87hf946bb3b756d0bd@mail.gmail.com>
Content-Disposition: inline
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 20 October 2009 14:50:09 Cyrill Gorcunov wrote:
> On 10/20/09, Denys Fedoryschenko <denys@visp.net.lb> wrote:
> > On Tuesday 20 October 2009 06:04:35 Cyrill Gorcunov wrote:
> >> On 10/20/09, Denys Fedoryschenko <denys@visp.net.lb> wrote:
> >> > On Tuesday 20 October 2009 00:22:39 Michal Ostrowski wrote:
> >> >> I'm assuming that there was a race in us sending patches at nearly
> >> >> the same
> >> >> time I'm convinced now that the flush_lock can die, and the patch I
> >> >> sent
> >> >> out kills it.
> >> >
> >> > o_O
> >> >
> >> > I am drowning in patches. Just let me know which one to test :-)
> >>
> >> Oh ;) Try out latest Michal's patch (and then mine). I'll continue
> >> digg this issue at next spare time slot. Thanks!
> >
> > Tried your patch, panic almost immediately
> > Here is a text of panic message over netconsole
> > http://www.nuclearcat.com/files/panic_pppoe3.txt
> > It is  different now, before it was pppoe_device_event, now in pppoe_rcv
>
> Thanks a lot! I'll back with new one in a couple of hours. Meanwhile i
> suppose you may try Michal's patch as well.
I did, it didn't help.
Maybe i can run some debugging options in kernel?
Also i can add debug(printk) lines in kernel if you want, to see where is bug 
appearing.
Note, i told to Michal, so will tell here, this pc is hyperthreading P4, as i 
know it is very good to trigger various SMP race conditions.
I can try also it with nosmp if u want.

