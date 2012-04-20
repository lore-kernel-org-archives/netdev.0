From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: RTM_NEWLINK not received by application when connecting
 multiple devices simultaneously
Date: Fri, 20 Apr 2012 08:14:00 -0700
Message-ID: <20120420081400.67a98836@nehalam.linuxnetplumber.net>
References: <CAKfDRXj+mydkzNFC8q2aE_JWHp3ie0cijC-itkm6sHLuZr98Fw@mail.gmail.com>
	<4F90208E.6070201@candelatech.com>
	<20120419075452.379f711b@s6510.linuxnetplumber.net>
	<CAKfDRXjCr0aDSDT8zN8A7_iNX6KAJwrR3NxaB8GAgz5oEiCB3w@mail.gmail.com>
	<CAKfDRXhAqFzPWAJkzhPdZGsUrtjex8uVwHBynCdvA+Zo6sjMig@mail.gmail.com>
	<20120419133635.7d816d67@nehalam.linuxnetplumber.net>
	<CAKfDRXih39RVnx1P72due=_v9-ORWf=YUfUTPKcvVbNzVuTLdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37781 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932528Ab2DTPOF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2012 11:14:05 -0400
In-Reply-To: <CAKfDRXih39RVnx1P72due=_v9-ORWf=YUfUTPKcvVbNzVuTLdw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Apr 2012 16:07:42 +0200
Kristian Evensen <kristian.evensen@gmail.com> wrote:

> Thank you very much for all the help.
> 
> >> I spent some more time debugging this now. It turns out that which
> >> interface is seen by my application is not random, it is always the
> >> first one that is connected. This indicates that the bug is that the
> >> netlink message contains information about more than one interface.
> >> However, I am not able to prove this.
> >
> > There is no filtering. A dump request always returns all interfaces.
> 
> I think maybe I didnt explain myself clearly enough, I am sorry. This
> does not happen when I dump interface info, but at the event of
> connecting two interfaces at the same time.
> 
> I have now converted the application to using libmnl, but I still see
> the same error. There is one message that is not received by my
> netlink socket, or at least, the application does not process it. Just
> in case it was bundled together with the message about the first
> interface, I tried adding a loop where I received the packets (similar
> to the one in the -dump example). However, this did not help.
> 
> -Kristian

Check if ip command catches the events (ip monitor).
What is the type of device? and what do you  mean by connecting?
(ie installing, doing admin up, operstate transition, carrier)
