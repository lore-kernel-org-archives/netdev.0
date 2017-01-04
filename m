From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH net-next v2 00/27] Allow passing of VLAN CFI bit through
 network stack
Date: Wed, 4 Jan 2017 01:13:33 +0100
Message-ID: <20170104001333.45bu4ezurq63pjwb@rere.qmqm.pl>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
 <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
 <20170103.163217.697324652959765171.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:37332 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759499AbdADAON (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 19:14:13 -0500
Content-Disposition: inline
In-Reply-To: <20170103.163217.697324652959765171.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 03, 2017 at 04:32:17PM -0500, David Miller wrote:
> From: Micha³ Miros³aw <mirq-linux@rere.qmqm.pl>
> Date: Tue,  3 Jan 2017 21:52:33 +0100 (CET)
> 
> > Dear NetDevs
> > 
> > This series removes an abuse of VLAN CFI bit in Linux networking stack.
> > Currently Linux always clears the bit on outgoing traffic and presents
> > it cleared to userspace (even via AF_PACKET/tcpdump when hw-accelerated).
> > 
> > This uses a new vlan_present bit in struct skbuff, and removes an assumption
> > that vlan_proto != 0 when VLAN tag is present.
> > 
> > As I can't test most of the driver changes, please look at them carefully.
> > 
> > The series is supposed to be bisect-friendly and that requires temporary
> > insertion of #define VLAN_TAG_PRESENT in BPF code to be able to split
> > JIT changes per architecture.
> > 
> > Best Regards,
> > Micha³ Miros³aw
 
> This patch series is really way too large.
> 
> You're going to have to find a way to combine related changes, or submit
> this as a series of logical sets, one at a time.

I have sent all the cleanups that don't depend on each other.
Please consider for applying.

Best Regards,
Micha³ Miros³aw
