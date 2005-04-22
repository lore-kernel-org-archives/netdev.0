From: Andi Kleen <ak@muc.de>
Subject: Re: Must every packet have a creating socket?
Date: Fri, 22 Apr 2005 13:39:46 +0200
Message-ID: <m1d5snyr99.fsf@muc.de>
References: <20050420172944.69275.qmail@web51501.mail.yahoo.com>
	<4266FFC4.6020305@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@redhat.com>, jamal <hadi@cyberus.ca>,
	linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <4266FFC4.6020305@hp.com> (Rick Jones's message of "Wed, 20 Apr
 2005 18:20:04 -0700")
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones <rick.jones2@hp.com> writes:

>> Can I think that every packet (e.g. IP packet) must
>> have a corresponding creating socket? (i.e. Must every
>> packet be created by a socket?)
>
> No.  ICMP messages come to mind - although I _suppose_ that since
> those are in response to other traffic, you could claim it was in
> response to something sent from a "socket" or "endpoint" - depends on
> how far away you consider it to still be  from a socket.

Actually Linux has kernel private sockets for ICMP.
Very old Linux didnt, but it required ugly special cases
in the transmit path, so it was removed.

-Andi
