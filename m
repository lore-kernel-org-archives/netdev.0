From: Andreas Steffen <andreas.steffen@strongswan.org>
Subject: Re: Kernel IPSec Questions
Date: Fri, 29 Jul 2011 09:03:52 +0200
Message-ID: <4E325B58.6030202@strongswan.org>
References: <CAL0-=Wwb+T_VYgMnOW9UiqQ2gVe8FaJCZgcFmHMLX1Yv3tVAdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: T C <tccheung1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sitav-80024.hsr.ch ([152.96.80.24]:58459 "EHLO strongswan.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755379Ab1G2H7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2011 03:59:19 -0400
In-Reply-To: <CAL0-=Wwb+T_VYgMnOW9UiqQ2gVe8FaJCZgcFmHMLX1Yv3tVAdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Terry,

here a repost of my email including the netdev list and fixing
the last URL which was wrong.

Here the definition of strongSwan's IPsec high level kernel interface

http://git.strongswan.org/?p=strongswan.git;a=blob;f=src/libhydra/kernel/kernel_ipsec.h;h=986e21fca1bbd109445e95d86dbf458095299573;hb=HEAD

and here the link to the kernel-netlink plugin which implements
configuration and management of IPsec Policies and SAs via XFRM

http://git.strongswan.org/?p=strongswan.git;a=blob;f=src/libhydra/plugins/kernel_netlink/kernel_netlink_ipsec.c;h=06720a0f4bddf9fde60288f796df0eca647ae995;hb=HEAD

Our plugin of course relies on the ipsec.h, netlink.h, rtnetlink.h,
and xfrm.h Linux header files which define the API of the XFRM Netlink
kernel interface

http://git.strongswan.org/?p=strongswan.git;a=tree;f=src/include/linux;h=a41d3e9a10954c47aff2efeb06576f323c039483;hb=HEAD

Much more documentation than the Linux header files and the XFRM kernel
source code itself does not exist.

Finally a link which shows how strongSwan installs, updates, queries
and deletes IPsec Policies and SAs

http://git.strongswan.org/?p=strongswan.git;a=blob;f=src/libcharon/sa/child_sa.c;h=cda150f8736d010cf8d897071427daf8a02a337a;hb=HEAD

Just look for all "hydra->kernel_interface" function calls.

Best regards

Andreas

On 07/29/2011 07:40 AM, T C wrote:
> Hi all,
> 
> I have some questions on how IPSec logic works in the kernel.  There might be
> a difference between when XFRM was introduced and prior.  If possible,
> I like to know both scenarios.  If not, at least from XFRM perspective would
> be very helpful.
> 
> Specifically, I am interested in knowing how does IPSec obtain the initial keys
> from IKE exchange (and likely from XFRM) to set up the SA.   Also what happens
> during rekeying?  Does the SA have to be terminated first, or somehow it can be
> rekey'ed and continue as the same SA?  I'll be using strongswan for IKE.
> 
> Function names and if possible some flow graphs would be greatly appreciated.
> 
> Thanks,
> Terry
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
======================================================================
Andreas Steffen                         andreas.steffen@strongswan.org
strongSwan - the Linux VPN Solution!                www.strongswan.org
Institute for Internet Technologies and Applications
University of Applied Sciences Rapperswil
CH-8640 Rapperswil (Switzerland)
===========================================================[ITA-HSR]==
