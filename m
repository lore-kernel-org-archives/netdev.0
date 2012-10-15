From: Joe Perches <joe@perches.com>
Subject: Re: regression when connecting to ipv6 localhost
Date: Mon, 15 Oct 2012 04:25:02 -0700
Message-ID: <1350300302.22442.25.camel@joe-AO722>
References: <CAO_aot5U16KLjqtXp2ZS7d+T0WvVY7OXPaA3t2bbN=uvboVV3Q@mail.gmail.com>
	 <1350242941.21172.17023.camel@edumazet-glaptop>
	 <CAO_aot7BQqob=V9MEDSFnmCCNsxgjghC5e3NuQonqY8GCkV1Og@mail.gmail.com>
	 <1350244485.21172.17077.camel@edumazet-glaptop>
	 <CAO_aot7wZAqqQForAe-9aLnALqm1LdeaEv+ZKqiw3V_DCfqjRw@mail.gmail.com>
	 <1350246314.21172.17139.camel@edumazet-glaptop>
	 <1350246414.21172.17144.camel@edumazet-glaptop>
	 <1350246481.21172.17147.camel@edumazet-glaptop>
	 <CAO_aot5xZevtZcCS37h9HR4Zkj_Q4ny_sj+NX7oYEvazAQjxLQ@mail.gmail.com>
	 <1350248858.21172.17197.camel@edumazet-glaptop>
	 <CAO_aot6w9yaWacK9kE66m+Lv0LWXY9hKzLH8b=1dp=23fo_W2A@mail.gmail.com>
	 <1350250542.21172.17229.camel@edumazet-glaptop>
	 <CAO_aot4RiTbUd=7L5e4btLEeJvgy0B3iswaXo8m3AP2qp9Z0TQ@mail.gmail.com>
	 <1350252091.21172.17257.camel@edumazet-glaptop>
	 <CAO_aot6j2TPe9yxnA1ktMQsfnnWF1XwmCrQUmCcfOqCqbc6dZA@mail.gmail.com>
	 <1350279753.21172.17290.camel@edumazet-glaptop>
	 <1350285275.22442.17.camel@joe-AO722>
	 <1350286790.21172.17414.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54525 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752249Ab2JOLZE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2012 07:25:04 -0400
In-Reply-To: <1350286790.21172.17414.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-15 at 09:39 +0200, Eric Dumazet wrote:
> On Mon, 2012-10-15 at 00:14 -0700, Joe Perches wrote:
> > On Mon, 2012-10-15 at 07:42 +0200, Eric Dumazet wrote:
> > > So ntpd doesnt listen on ntp messages sent on ::1

> You can have a valid patch that uncover a bug in an application, it
> happens everyday.

<shrug> you can have a behavior that important applications
rely on and not be able to change the kernel because of it.

It looks more like a recently introduced app defect though.

> That would be really awesome, given Jan is not a kernel developer, we
> cannot really ask him to do this himself.

Jan's using a newer version of ntp than you are.
https://bugs.archlinux.org/task/31775
ntp 4.2.6.p5-11

Perhaps the defect was introduced in the ntp code with
this change:

http://bk.ntp.org/ntp-stable/lib/isc/unix/interfaceiter.c?PAGE=diffs&REV=4e12bf8dJoMBgRoYzI9851nTqVBhgQ
