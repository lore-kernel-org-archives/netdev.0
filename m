From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netxen_nic: unregister_netdevice error
Date: Tue, 31 May 2011 11:48:46 +0200
Message-ID: <1306835326.2809.1.camel@edumazet-laptop>
References: <4DE4877C.1070704@gmail.com>  <4DE4B31A.3090201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>
To: WeipingPan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36795 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324Ab1EaJsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2011 05:48:50 -0400
Received: by wwa36 with SMTP id 36so4672488wwa.1
        for <netdev@vger.kernel.org>; Tue, 31 May 2011 02:48:49 -0700 (PDT)
In-Reply-To: <4DE4B31A.3090201@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 31 mai 2011 =C3=A0 17:21 +0800, WeipingPan a =C3=A9crit :
> On 05/31/2011 02:15 PM, WeipingPan wrote:
> > hi,
> >
> > When test bonding broadcast mode I met a problem.
> > modprobe -r bonding will fail after I ping broadcast address.
> >
> > I find that the problem only shows up when I use netxen_nic driver.
> > When use ixgbe and bn2x2 driver, no problem occurs.
> >
> > I use RHEL 6.2, kernel 2.6.32-131.0.15.el6.i686,
> > Can anybody confirm this bug using 2.6.39 or upstream ?
> >
> > many thanks
> > Weiping Pan
> >
> I got a machine to test the=20
> upstream,55922c9d1b84b89cb946c777fddccb3247e7df2c
> the problem disappears.
>=20
> many thanks
> Weiping Pan

Might be solved by commit fc75fc8339e772716744 or=20

commit 332dd96f7ac15e937088fe11f15c (net/dst: dst_dev_event() called
after other notifiers) and commit ef885afbf8a37689 ((net: use
rcu_barrier() inrollback_registered_many)





