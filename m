From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 1/8] net: Kill hold_net release_net
Date: Wed, 11 Mar 2015 12:34:40 -0500
Message-ID: <877funa15b.fsf@x220.int.ebiederm.org>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	<CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	<87d25hrv9m.fsf@x220.int.ebiederm.org>
	<20150219.144929.1003473344851168804.davem@davemloft.net>
	<87h9tu114z.fsf_-_@x220.int.ebiederm.org>
	<87vbi7fq92.fsf_-_@x220.int.ebiederm.org>
	<87pp8ffq63.fsf_-_@x220.int.ebiederm.org>
	<1426092952.11398.48.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	netdev@vger.kernel.org, stephen@networkplumber.org,
	nicolas.dichtel@6wind.com, roopa@cumulusnetworks.com,
	hannes@stressinduktion.org, ddutt@cumulusnetworks.com,
	vipin@cumulusnetworks.com, shmulik.ladkani@gmail.com,
	dsahern@gmail.com, Julian Anastasov <ja@ssi.bg>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:41728 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbbCKRiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 13:38:22 -0400
In-Reply-To: <1426092952.11398.48.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Wed, 11 Mar 2015 09:55:52 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Wed, 2015-03-11 at 11:35 -0500, Eric W. Biederman wrote:
>> hold_net and release_net were an idea that didn't work.  Kill them
>> it is long past due.
>
> Care to describe a bit more what is not working ?

Long ago and far away when I was first starting the network namespace
implementation hold_net and release_net were based on a misunderstanding
of what dev_hold and dev_release do.  I thought they were just for
debugging.  I cloned the concept and then later realized it added no
benefit to network namespaces.  The code has been disabled for more years
than I care to remember, and it is just dead weight now.

So it makes sense to remove the definitions now.

Eric
