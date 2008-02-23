From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: Error on ip route replace command
Date: Sat, 23 Feb 2008 15:44:48 +0900
Message-ID: <b25c3fa70802222244g1d3d08ecme90f4395c1c5505c@mail.gmail.com>
References: <00a701c875a1$58f70fb0$b400a8c0@ASUSFSG>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Francesco Saverio Giudice" <info@fsgiudice.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.187]:60770 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345AbYBWGot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 01:44:49 -0500
Received: by rv-out-0910.google.com with SMTP id k20so435228rvb.1
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2008 22:44:48 -0800 (PST)
In-Reply-To: <00a701c875a1$58f70fb0$b400a8c0@ASUSFSG>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/2/23, Francesco Saverio Giudice <info@fsgiudice.com>:
> Hi All,
>
> I have a problem with kernel 2.6.24.
>
> Having a running configuration using Shorewall and restarting it I got
> follow error:
> RTNETLINK answers: File exists
>
> Tom Eastep, Shorewall creator, told me to inform you about the problem.
>
> Here is the mail:
> ------------------------------------------------------------
> Francesco Saverio Giudice wrote:
> > Hi Tom,
> >
> > I get the error:
> >
> > ---------
> > # ip route add 1.2.4.5 dev eth3
> > # ip route replace 1.2.4.5 dev eth3
> > RTNETLINK answers: File exists
> > ---------
> >
> > I have to patch kernel or something else ?
> >
>
> You should report it at netdev@vger.kernel.org (that's where the Linux
> networking developers hang out). This failure does not occur with kernel
> 2.6.22 and iproute2 ss070710:
>
> gateway:~ # ip route add 1.2.4.5 dev eth0
> gateway:~ # ip route replace 1.2.4.5 dev eth0
> gateway:~ # ip route del 1.2.4.5
>
> -Tom
> --
> Tom Eastep    \ Nothing is foolproof to a sufficiently talented fool
> Shoreline,     \ http://shorewall.net
> Washington USA  \ teastep@shorewall.net
> PGP Public Key   \ https://lists.shorewall.net/teastep.pgp.key
>
> ------------------------------------------------------------
>
> Best Regards
>
> Francesco Saverio Giudice
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

Francesco,
It was fixed by 936f6f8e1bc46834bbb3e3fa3ac13ab44f1e7ba6 and
c18865f39276435abb9286f9a816cb5b66c99a00.
Please try with lastest git source

Joonwoo.
