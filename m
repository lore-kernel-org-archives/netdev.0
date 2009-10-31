From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/6] Bonding simplifications and netns support
Date: Fri, 30 Oct 2009 17:27:45 -0700
Message-ID: <m1pr84jtku.fsf@fess.ebiederm.org>
References: <m1tyxhwxah.fsf@fess.ebiederm.org>
	<20091030.124153.00934819.davem@davemloft.net>
	<21200.1256937150@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:54107 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757530AbZJaA1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 20:27:45 -0400
In-Reply-To: <21200.1256937150@death.nxdomain.ibm.com> (Jay Vosburgh's message of "Fri\, 30 Oct 2009 14\:12\:30 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh <fubar@us.ibm.com> writes:

> 	I put patches 1-7 on a recent net-next-2.6, and from a simple
> "insmod bonding.ko; rmmod bonding" I'm seeing the following:
>

> 	Any thoughts?  I have not as yet investigated further.

I just tried to reproduce this, without luck.  My best guess is that there is
something odd particular to your setup. 

A simple while :; modprobe bonding ; rmmod bonding ; done runs without problems
for me.

Eric
