From: "Erdt, Ralph" <ralph.erdt@fkie.fraunhofer.de>
Subject: AW: AW: AW: RFC: replace packets already in queue
Date: Tue, 3 Jul 2012 07:29:35 +0000
Message-ID: <FB112703C4930F4ABEBB5B763F96491139379DC7@MAILSERV2A.lorien.fkie.fgan.de>
References: <FB112703C4930F4ABEBB5B763F96491139378722@MAILSERV2A.lorien.fkie.fgan.de>
	 <4FEC854E.8080603@hp.com>
	 <FB112703C4930F4ABEBB5B763F96491139378E5A@MAILSERV2A.lorien.fkie.fgan.de>
	 <1340960817.15719.6.camel@edumazet-glaptop>
	 <FB112703C4930F4ABEBB5B763F964911393795D6@MAILSERV2A.lorien.fkie.fgan.de>
	 <1341214310.5269.27.camel@edumazet-glaptop>
	 <FB112703C4930F4ABEBB5B763F96491139379643@MAILSERV2A.lorien.fkie.fgan.de>
	 <4FF20557.4090501@gmail.com> <1341266168.22621.466.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Rick Jones <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	=?iso-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailguard.fkie.fraunhofer.de ([128.7.3.5]:35677 "EHLO
	a.mx.fkie.fraunhofer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277Ab2GCH3j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 03:29:39 -0400
In-Reply-To: <1341266168.22621.466.camel@edumazet-glaptop>
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > If I were you, I would use a tun/tap interface and manage a private
> > packet queue in userspace. This way, you wouldn't have to manage the
> overhead of porting your kernel code to every new kernel versions.
> >
> 
> This seems a good idea.
> 
> Then you can do other coalescing stuff, like TCP ACK that could be
> aggregated to single ACK as well.

Thanks for the idea. But this is option when just doing the replace thing.
But the charm of the qdisc solution is the complete integration to TC. It's complete compatible to the other options, so that you can create a bigger TC rule set. And creating the rules is a standard operation for the administrators - they know TC.

In terms of the other coalescing stuff (we didn't use TCP, because it's not possible) - it's already done in the device "driver" I mentioned. Yes, we can extend the "driver", but the qdisc solution has the benefit that there is a clear separation.

Nevertheless we will discuss the idea internally. Maybe the group got another idea based on this.
