From: Thomas Spatzier <thomas.spatzier@de.ibm.com>
Subject: Re: [patch 4/10] s390: network driver.
Date: Mon, 29 Nov 2004 17:41:42 +0100
Message-ID: <OF7E76C3BE.B1D182D3-ONC1256F5B.005B3E84-C1256F5B.005BB584@de.ibm.com>
References: <Pine.LNX.4.61.0411291602330.18143@hibernia.jakma.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261757AbUK2QmI@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.61.0411291602330.18143@hibernia.jakma.org>
To: Paul Jakma <paul@clubi.ie>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org





Paul Jakma <paul@clubi.ie> wrote on 29.11.2004 17:30:23:
> Well, if the kernel is going to queue these packets without notifying
> us, we absolutely *must* have some way to flush those queues. Sending
> stale packets many minutes after the application generated them could
> have serious consequences for routing (eg, think sending RIP, IPv4
> IRDP or v6 RAs which are no longer valid - client receives them and
> installs routes which are long invalid and loses connectivity to some
> part of the network).
>

Yes, for the examples you mentioned the app should better be notified.
However, AFAICS, there are no such notification mechanisms on a
per-packet basis implemented in the kernel.
And I doubt that they are going to be implemented.

> I'd be very interested to hear advice from the kernel gurus (eg "god,
> dont be so stupid, do xyz in your application instead"). We can
> accomodate whatever kernel wants as long as its workable.

Good suggestion, if anyone has an interesting and feasible solution
I will be happy to integrate it. So far, however, it don't see one and I
would point people being worried about lost packets to TCP.


Regards,
Thomas.
