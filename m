From: Jie Yang <Jie.Yang@Atheros.com>
Subject: RE: alt1c: ethernet driver bug
Date: Fri, 9 Oct 2009 11:37:11 +0800
Message-ID: <72981EBCFD196144B7C6999B9FC34A9A49493F5B61@SHEXMB-01.global.atheros.com>
References: <20091006161048.6b52b6be@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 175.210.DSNET ([203.110.175.210]:60997 "EHLO mail.atheros.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758895AbZJIDhv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 23:37:51 -0400
In-Reply-To: <20091006161048.6b52b6be@nehalam>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Stephen Hemminger <shemminger@vyatta.com> wrote:
> Sent: Wednesday, October 07, 2009 7:11 AM
> To: Jie Yang
> Cc: netdev@vger.kernel.org
> Subject: alt1c: ethernet driver bug
>
> > http://bugzilla.kernel.org/show_bug.cgi?id=14336
> >
> >            Summary: [Pardus] Soft Lockup Problem with
> Attansic Ethernet
> >                     Card
> >            Product: Networking
> >            Version: 2.5
> >     Kernel Version: 2.6.30.8
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: high
> >           Priority: P1
> >          Component: IPV4
> >         AssignedTo: shemminger@linux-foundation.org
> >         ReportedBy: badibere@gmail.com
> >         Regression: No
> >
> >
> > I have soft lockup problem with attansic ethernet card while
> > activating eth0 interface.
> >
> > My ethernet card is 09:00.0 Ethernet controller: Attansic
> Technology Corp.
> > Device 1063 (rev c0)
> >
> > If I try to activate eth0 interface while network cable is
> pluged in,
> > then everything freezes.
> >
> > If I try to activate eth0 interface while network cable
> isn't pluged
> > in, then no problem. But, if i plug in, again freezes.
> >
> > My /var/log/syslog is in attachment.
> >
>
> this is what was in the bug attachment
>
> Oct  7 00:53:33 baDibere kernel: [   16.162099] atl1c
> 0000:09:00.0: enabling device (0000 -> 0002)
> Oct  7 00:53:33 baDibere kernel: [   16.162117] atl1c
> 0000:09:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
> Oct  7 00:53:33 baDibere kernel: [   16.162141] atl1c
> 0000:09:00.0: setting latency timer to 64
> Oct  7 00:53:33 baDibere kernel: [   16.162247] atl1c
> 0000:09:00.0: PME# disabled
> Oct  7 00:53:33 baDibere kernel: [   16.162266] atl1c
> 0000:09:00.0: PME# disabled
> Oct  7 00:53:33 baDibere kernel: [   16.230835] atl1c
> 0000:09:00.0: version 1.0.0.1-NAPI
> Oct  7 00:55:57 baDibere kernel: [  169.943463] atl1c
> 0000:09:00.0: Unable to allocate MSI interrupt Error: -22 Oct
>  7 00:55:57 baDibere kernel: [  169.943576] atl1c
> 0000:09:00.0: atl1c: eth0 NIC Link is Up<100 Mbps Full Duplex>
>
when "pci_enable_msi" failed, I will also request_irq, so it should not be a problem.
the message "NIC Link is Up<100 Mbps Full Duplex>" demonstrate the atl1c interrupt has worked.

