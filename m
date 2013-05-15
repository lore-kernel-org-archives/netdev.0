From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Patch iproute2] vxlan: use 8472 as default dst port
Date: Wed, 15 May 2013 14:42:01 -0400
Message-ID: <OF1177AC77.13B8F09E-ON85257B6C.0064777A-85257B6C.0066B974@us.ibm.com>
References: <1368616270-5775-1-git-send-email-amwang@redhat.com>	<OFA8084FAB.8443890D-ON85257B6C.003F1FAB-85257B6C.003F65F2@us.ibm.com>
	<20130515095322.275c9b2f@nehalam.linuxnetplumber.net>	<OFF100C7ED.6500FAB3-ON85257B6C.005DCF7C-85257B6C.005F309B@us.ibm.com> <20130515104825.5cbeaee3@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:35392 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759677Ab3EOSmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 14:42:12 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 15 May 2013 12:42:11 -0600
In-Reply-To: <20130515104825.5cbeaee3@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 05/15/2013 01:48:25 PM:

> From: Stephen Hemminger <stephen@networkplumber.org>
> 
> Sorry, this is a kernel bug.
> Kernel shouldn't bind on module load, needs to do it later when
> device is created. I will fix.

Sorry, didn't see this before last send, and fine, but if
ip changes the port for listens too, then existing users will
still get a new port by default, as soon as they get a new
"iproute2" (instead of as soon as they get a new kernel). But filter
rules and scripts that "know" the old port still won't work -
how is this better than changing the kernel default?

I think in either case, if you care what port it is, you
should specify it explicitly, always. Whether iproute2 or the
kernel makes it different, it'll break (or not) in exactly the same
ways for those who didn't.

                                                +-DLS
