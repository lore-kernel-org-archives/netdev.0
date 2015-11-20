From: Tom Herbert <tom@herbertland.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 16:15:39 -0800
Message-ID: <CALx6S36U1e14JEH1bBaJDg3xGRxtnr=7u94opFbD2M0mJhedwQ@mail.gmail.com>
References: <CAKD1Yr2OgJT0GsrTuws0oapobrU+ML3NpBNBXizg6q035PH4MA@mail.gmail.com>
	<20151119.005318.838757439536205791.davem@davemloft.net>
	<CANP3RGcPRzSL06qZB9oewrvN_AUUodnYzXQO=itoK40z64x8Yw@mail.gmail.com>
	<20151119.104811.1447518072450380661.davem@davemloft.net>
	<1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S363gYA37GnEuArp+PKVjFdLchB_66zuLF5kJnSFKF4t6Q@mail.gmail.com>
	<1447969264.22599.253.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S374xUUzWXUgA27PubceyDckrrfTiq7wvkLxXa0NacqqZA@mail.gmail.com>
	<1447970875.22599.265.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S35CxmsN6Cx0BXCyqzWE67HF9SwTPAyzRnbVFKun8AOTYQ@mail.gmail.com>
	<1447972381.22599.278.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S35Q_pc-vBNpA0hipn5K-vSmPDsV-V=D13sODESNO7Htdw@mail.gmail.com>
	<CAKD1Yr1JWP4jsRHd41NMHZsNbK5_b_kG=Z3AWYd=YpHwpgDgFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	zenczykowski <zenczykowski@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:36128 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161207AbbKTAPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 19:15:40 -0500
Received: by igcph11 with SMTP id ph11so438824igc.1
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 16:15:39 -0800 (PST)
In-Reply-To: <CAKD1Yr1JWP4jsRHd41NMHZsNbK5_b_kG=Z3AWYd=YpHwpgDgFg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 19, 2015 at 4:09 PM, Lorenzo Colitti <lorenzo@google.com> wrote:
> On Fri, Nov 20, 2015 at 9:04 AM, Tom Herbert <tom@herbertland.com> wrote:
>> or to start killing connections based on some arbitrary policy when
>> under memory pressure.
>
> You mean like the OOM killer starts killing entire processes based on
> some arbitrary policy when under memory pressure? :-)

No, I mean something that kills connections where previously this did
not happen. The fact that this is done at the process level does not
justify that it is a right to at do connections. Besides, if you
really intend to do this then provide a privileged process a means to
close *any* open file descriptor in the system (why stop at TCP
sockets)!
