From: Sonny <smaniaol@gmail.com>
Subject: Re: kernel 2.4 vs 2.6 Traffic Controller performance
Date: Wed, 3 Oct 2007 16:31:15 +0800
Message-ID: <9dbec86d0710030131t3722d022w17d9738396333eee@mail.gmail.com>
References: <9dbec86d0710022314o6db2b0baua6db543d52f312b6@mail.gmail.com>
	 <47033E10.6090505@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:6112 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753852AbXJCIbQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 04:31:16 -0400
Received: by wx-out-0506.google.com with SMTP id h31so3902168wxd
        for <netdev@vger.kernel.org>; Wed, 03 Oct 2007 01:31:15 -0700 (PDT)
In-Reply-To: <47033E10.6090505@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/3/07, Eric Dumazet <dada1@cosmosbay.com> wrote:
> Sonny a =E9crit :
> > Hello
> > This is a repost, there seems to have a misunderstanding before.
> >
> > I hope this is the right place to ask this. Does any know if there =
is a
> > substantial difference in the performance of the traffic controller
> > between kernel 2.4 and 2.6. We tested it using 1 iperf server and u=
se
> > 250 and 500 clients, altering the burst.
> >
> > This is the set-up:
> > iperf client -  router (w/ traffic controller) - iperf server
> >
> > We use the top command inside the router to check the idle time of =
our
> > router to see this. The results we got from the 2.4 kernel shows
> > around 65-70% idle time while the 2.6 shows
> > 60-65% idle time. We tried to use MRTG and we're not getting any
> > results either. We want to know if we could improve the bandwidth b=
y
> > upgrading the kernel, else we would have to get a new bandwidth
> > manager.  Have anyone performed a similar test or can suggest a bet=
ter
> > way to do this. Thanks in advance.
> > -
> Hi Sonny
>
> I am not sure what you are asking here. 65-70% idle time (or 60-65%) =
is fine.
>
> 2.6 is also not very meaningfull, there are a lot of changes between =
2.6.0 and
> 2.6.23 :)
>
we're using 2.6.22

> Why should you upgrade kernel ?
we would like to test the difference bet 2 kernels performance

> What bandwidth do you handle ?
10 mbps

> What kind of platform is it ? (a new kernel wont help much if its a r=
eal old
> machine, or old NICs)
it's a P IV 2.8 GHz HT with 512 MB
>
> You seem to have some bandwidth problem but focus on cpu affairs...
Bandwidth is not a problem, we can get 10mbps without a hitch. But we
would like to know the scalability on the CPU vs the number of
clients. So far, for both kernels, we're getting 50% CPU utilization
using 500 clients and 384 burst kbps each.
