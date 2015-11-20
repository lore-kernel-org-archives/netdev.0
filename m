From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Fri, 20 Nov 2015 09:09:00 +0900
Message-ID: <CAKD1Yr1JWP4jsRHd41NMHZsNbK5_b_kG=Z3AWYd=YpHwpgDgFg@mail.gmail.com>
References: <CAKD1Yr2OgJT0GsrTuws0oapobrU+ML3NpBNBXizg6q035PH4MA@mail.gmail.com>
 <20151119.005318.838757439536205791.davem@davemloft.net> <CANP3RGcPRzSL06qZB9oewrvN_AUUodnYzXQO=itoK40z64x8Yw@mail.gmail.com>
 <20151119.104811.1447518072450380661.davem@davemloft.net> <1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
 <CALx6S363gYA37GnEuArp+PKVjFdLchB_66zuLF5kJnSFKF4t6Q@mail.gmail.com>
 <1447969264.22599.253.camel@edumazet-glaptop2.roam.corp.google.com>
 <CALx6S374xUUzWXUgA27PubceyDckrrfTiq7wvkLxXa0NacqqZA@mail.gmail.com>
 <1447970875.22599.265.camel@edumazet-glaptop2.roam.corp.google.com>
 <CALx6S35CxmsN6Cx0BXCyqzWE67HF9SwTPAyzRnbVFKun8AOTYQ@mail.gmail.com>
 <1447972381.22599.278.camel@edumazet-glaptop2.roam.corp.google.com> <CALx6S35Q_pc-vBNpA0hipn5K-vSmPDsV-V=D13sODESNO7Htdw@mail.gmail.com>
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
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:34843 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532AbbKTAJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 19:09:20 -0500
Received: by ykba77 with SMTP id a77so135520993ykb.2
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 16:09:20 -0800 (PST)
In-Reply-To: <CALx6S35Q_pc-vBNpA0hipn5K-vSmPDsV-V=D13sODESNO7Htdw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2015 at 9:04 AM, Tom Herbert <tom@herbertland.com> wrote:
> or to start killing connections based on some arbitrary policy when
> under memory pressure.

You mean like the OOM killer starts killing entire processes based on
some arbitrary policy when under memory pressure? :-)
