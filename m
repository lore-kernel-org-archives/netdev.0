From: Corcodel Marian <asd@marian1000.go.ro>
Subject: Re: [PATCH net v4] r8169: Bad implementation of netif_carrier_*
Date: Thu, 11 Feb 2016 13:41:23 +0200
Message-ID: <1455190883.2484.9.camel@marian1000.go.ro>
References: <1455172063-1959-1-git-send-email-asd@marian1000.go.ro>
	 <20160211.033915.51059595679987845.davem@davemloft.net>
	 <1455187969.3447.4.camel@marian1000.go.ro>
	 <20160211.061250.1340671752357908695.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-227-192.residential.rdsnet.ro ([5.14.227.192]:55459 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140AbcBKLl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 06:41:28 -0500
In-Reply-To: <20160211.061250.1340671752357908695.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-02-11 at 06:12 -0500, David Miller wrote:
> From: Corcodel Marian <asd@marian1000.go.ro>
> Date: Thu, 11 Feb 2016 12:52:49 +0200
> 
> > On Thu, 2016-02-11 at 03:39 -0500, David Miller wrote:
> >> From: Corcodel Marian <asd@marian1000.go.ro>
> >> Date: Thu, 11 Feb 2016 08:27:43 +0200
> >> 
> >> >   On probe stage what carrier to stop and rest two situation
> >> >   netif_carrier_* is slow and disturbing autonegociation
> process.
> >> > 
> >> > Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
> >> 
> >> This doesn't tell us at all why your change is valid.  You aren't
> >> going into the details of what you mean by "disturbing" and why it
> >> being "slow" is really a problem.
> >> 
> >> In general, your patches are of a very low quality.  You give
> never
> >> give us enough information to properly evaluate your patch.
> >> 
> >> It is unlikely that even one of your patches will be applied by
> >> me until you fix this fundamental problem with your submissions.
> > 
> > May bee netif_carrier_* is good on slow changes of link good status
> of
> > interrupt ,is unable to keep track changes from link good
> interrupt.
> 
> You're still not telling us anything.
> 
> The situation with your submissions is not improving.
> 
> Sorry.
 
On my opinion  dmesg  must have one line with "link down" and one line
with "link up"
One mee result of dmesg | grep r8169 is :

$ dmesg | grep r8169
[    2.476418] r8169: module verification failed: signature and/or
required key missing - tainting kernel
[    2.477605] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    2.478760] r8169 0000:01:00.0 eth0: RTL8102e at 0xf842a000,
00:22:15:4b:fd:ce, XID 14a00000 IRQ 24
[   39.513256] r8169 0000:01:00.0 eth0: link down
[   39.513284] r8169 0000:01:00.0 eth0: link down
[   53.153284] r8169 0000:01:00.0 eth0: link up

On good cases, on worst case "link down" and "link up" messages will
succeed from 3-4 times and produce unlikely result with netif_carrier_*
on  combination.
