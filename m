From: <Narendra_K@Dell.com>
Subject: RE: Generic interface to make physical port number used by a
 netdevice available to user space
Date: Mon, 27 May 2013 18:39:00 +0530
Message-ID: <E31FB011129F30488D5861F383904915210B96144A@BLRX7MCDC201.AMER.DELL.COM>
References: <20130522075331.GA1363@fedora-17-guest.blr.amer.dell.com>
 <20130523093421.3b20a0bd@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:10760 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756122Ab3E0NXS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 09:23:18 -0400
In-Reply-To: <20130523093421.3b20a0bd@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Thursday, May 23, 2013 10:04 PM
> To: K, Narendra
> Cc: netdev@vger.kernel.org
> Subject: Re: Generic interface to make physical port number used by a
> netdevice available to user space
> 
> On Wed, 22 May 2013 13:24:15 +0530
> <Narendra_K@Dell.com> wrote:
> > It would be great to know list's thoughts on  'dev_id' being used as
> > the interface to make the physical port number information used by
> > netdevice available to user space or do we need a new sysfs attribute for
> the same.
> >
> > Note: I think in the scenario of SRIOV VF devices assigned to guest
> > and being bonded, additional information would be needed to
> > differentiate the network controller in the host.  But I suppose it is a
> different problem than this.
> >
> > References to related discussions:
> > 1. [PATCH net-next] bnx2x: Add Nic partitioning mode (57712)
> > http://marc.info/?l=linux-netdev&m=129098288709528&w=2
> > 2. [PATCH net-next] bonding: Support for multi function NIC devices
> > http://marc.info/?l=linux-netdev&m=134240221118594&w=2
> >
> > Thank you,
> >
> 
> One idea would be to reuse the mostly outdated if_port field.
> As far as I can see only drivers using it are legacy drivers which support AUI vs.
> TP back in the old bad days of BNC Ethernet.

Hi Stephen, thank you.

I think if_port or dev_id would be fine. The difference seems to be  that dev_id is already exported to sysfs.

With regards,
Narendra K
Linux Engineering
Dell Inc.
 
