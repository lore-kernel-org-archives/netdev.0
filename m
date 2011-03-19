From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH] Add useful per-connection TCP stats for diagnosis purpose.
Date: Fri, 18 Mar 2011 21:33:45 -0700
Message-ID: <AANLkTikrJ7A-ygc9JnkvfBpRaKjL0fKeta+9ASLDr0rg@mail.gmail.com>
References: <1300349189-2731-1-git-send-email-hkchu@google.com>
	<1300351330.10164.712.camel@edumazet-laptop>
	<AANLkTi=sLkXreC3LNsDuFDSeNMebr+ScMc12=gngd2cc@mail.gmail.com>
	<20110317142030.62af785a@nehalam>
	<AANLkTi=W-=8zhQpfJZ=DrDyUCwrT==5JkwRBiHaDkVXK@mail.gmail.com>
	<1300428324.2881.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:61844 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183Ab1CSEdt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2011 00:33:49 -0400
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p2J4Xlxh025467
	for <netdev@vger.kernel.org>; Fri, 18 Mar 2011 21:33:47 -0700
Received: from gyg13 (gyg13.prod.google.com [10.243.50.141])
	by hpaq7.eem.corp.google.com with ESMTP id p2J4XjwB021434
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 18 Mar 2011 21:33:46 -0700
Received: by gyg13 with SMTP id 13so1717576gyg.10
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2011 21:33:45 -0700 (PDT)
In-Reply-To: <1300428324.2881.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2011 at 11:05 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
>
> Le jeudi 17 mars 2011 =E0 21:33 -0700, Jerry Chu a =E9crit :
>
> > Yes I'm familiar with ss and how inet_csk_diag_fill() calls into
> > tcp_diag_get_info(),..., etc. Like I mentioned previously the netli=
nk
> > interface
> > requires a new version of reader app (e.g., ss) to ship every time =
a new
> > counter is added and exported by the kernel, whereas /proc/net/tcp =
does
> > not have such a problem.
> >
> > Anyway I can add a INET_DIAG_INFO_EXT of some sort to netlink in
> > addition to /proc/net/tcp. That's easy to do.
> >
>
> I suggest adding a getsockopt() or something to gather stats for one
> socket. On a loaded machine, /proc/net/tcp is damn slow.

I'm well aware of the past, hideous O(n**2) problem of reading
/proc/net/tcp but I
thought the problem has been fixed by Tom Herbert a while back, no?
(See=A0http://marc.info/?l=3Dlinux-netdev&m=3D127588123429437&w=3D2)

>
> We have TCP_INFO, we could add TCP_INFO_EXT, but taking care of choos=
ing
> an interface allowing for extension of the structure.

Ok.

Jerry
