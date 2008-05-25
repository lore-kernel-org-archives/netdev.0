From: Glen Turner <gdt@gdt.id.au>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
	IRQF_SAMPLE_RANDOM
Date: Mon, 26 May 2008 00:39:49 +0930
Message-ID: <1211728189.5913.71.camel@andromache>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com>
	 <482C7B18.6060003@garzik.org> <482C7E53.3050300@hp.com>
	 <482C8184.2030906@garzik.org> <482C8550.5000909@intel.com>
	 <482C8D4D.3040702@garzik.org> <20080516132107.GA11304@csclub.uwaterloo.ca>
	 <20080516161029.44ded734@core> <20080516173610.GA27126@csclub.uwaterloo.ca>
	 <20080516191125.46f59ad6@core>
	 <a24804730805162155m72e6b40aweb8822515c880c50@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Jeff Garzik <jeff@garzik.org>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Rick Jones <rick.jones2@hp.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chris Peterson <cpeterso@cpeterso.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth6445.sa.adsl.internode.on.net ([150.101.30.44]:33774 "EHLO
	aix.gdt.id.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753772AbYEYPLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 May 2008 11:11:13 -0400
In-Reply-To: <a24804730805162155m72e6b40aweb8822515c880c50@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-05-16 at 21:55 -0700, Chris Peterson wrote:
> * network drivers could use IRQF_SAMPLE_URANDOM

Is it permissable for /dev/urandom to degrade to be externally
influenced
by a hostile party?

For example, /dev/random has run out. So the output of /dev/urandom is
now
determined by previous values of /dev/random.  I then send in a stack of
network packets at regular intervals. So the output of /dev/urandom is
now greatly determined by those packets.  My search space for the
resulting
key is small since /dev/urandom appears to be random, but in fact is
periodic.

I'll also note that there is a huge number of periodic packets seen by
hosts on quiet networks -- such as a preparation VLAN where a system
administrator might choose to run up a new machine.

