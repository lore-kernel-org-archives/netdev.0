From: "Jim McCullough" <jim.mccullough@gmail.com>
Subject: Re: E1000 stopped transmitting in rc3.
Date: Sat, 29 Apr 2006 02:46:18 -0400
Message-ID: <ae023b600604282346w79ab0e8fx409c83634f2492d2@mail.gmail.com>
References: <20060428.001440.33235399.davem@davemloft.net>
	 <39fa70c7844cbb7240b98446e0940de7@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: "David S. Miller" <davem@davemloft.net>, davej@redhat.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.187]:36367 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751485AbWD2GqU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Apr 2006 02:46:20 -0400
Received: by nproxy.gmail.com with SMTP id o60so2576172nfa
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 23:46:18 -0700 (PDT)
To: "Auke Kok" <sofar@foo-projects.org>
In-Reply-To: <39fa70c7844cbb7240b98446e0940de7@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From what I have seen currently, the issue is resolved.  Based on a
test across  multiple systems on x86-64, i386,  and ia64 builds.

On 4/28/06, Auke Kok <sofar@foo-projects.org> wrote:
>
>
> On Fri, 28 Apr 2006 00:14:40 -0700 (PDT), "David S. Miller" <davem@davemloft.net> wrote:
> > From: Auke Kok <sofar@foo-projects.org>
> > Date: Thu, 27 Apr 2006 18:54:28 -0700
> >
> >> Dave Jones wrote:
> >> > With 2.6.17-rc3, my E1000 won't get a dhcp lease.
> >> > Looking at tcpdump and ifconfig output, it's easy to see why.
> >> > It's recieving packets, but the packets transmitted field
> >> > of ifconfig never increases.
> >> >
> >> > The last version I have built that worked ok was 2.6.17rc2-git3
> >>
> >> *puzzled*
> >>
> >> the only patch between 2.6.17rc2 and 2.6.17rc3 contains an rx-path
> > patch, but
> >> nothing that affects tx. All the other patches sent earlier are queued
> > for
> >> 2.6.18 so they don't apply.
> >
> > If the rx path is corrupting the packets or providing bad
> > checksums, there will be nothing to transmit back.
> >
> > So RX changes could explain the behavior.
>
> Jim sent me a private message that his colleagues messed up the build, and that it is working correctly now, right Jim?
>
> Cheers,
>
> Auke
>
>
>


--
Jim McCullough
