From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v6] net/hsr: Add support for the High-availability
 Seamless Redundancy protocol (HSRv0)
Date: Mon, 04 Nov 2013 14:03:05 -0800
Message-ID: <1383602585.28651.10.camel@joe-AO722>
References: <527167C7.4030305@xdin.com> <1383164122.9435.41.camel@joe-AO722>
	 <5277F6D6.9040807@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Javier Boticario <jboticario@gmail.com>,
	"balferreira@googlemail.com" <balferreira@googlemail.com>,
	=?ISO-8859-1?Q?El=EDas?= Molina =?ISO-8859-1?Q?Mu=F1oz?=
	<elias.molina@ehu.es>
To: Arvid Brodin <arvid.brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0222.hostedemail.com ([216.40.44.222]:60143 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751155Ab3KDWDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 17:03:11 -0500
In-Reply-To: <5277F6D6.9040807@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-04 at 20:34 +0100, Arvid Brodin wrote:
> On 2013-10-30 21:15, Joe Perches wrote:
> > On Wed, 2013-10-30 at 21:10 +0100, Arvid Brodin wrote:
> >> High-availability Seamless Redundancy ("HSR") provides instant failover
> >> redundancy for Ethernet networks. It requires a special network topology where
> >> all nodes are connected in a ring (each node having two physical network
> >> interfaces). It is suited for applications that demand high availability and
> >> very short reaction time.
> > 
> > Thanks Arvid.  Maybe add a MAINTAINERS entry too?
> 
> Something like this?

Yes, with a nit below:

>  S:     Maintained
>  F:     drivers/net/usb/hso.c
>  
> +HSR NETWORK PROTOCOL
> +M:     Arvid Brodin <arvid.brodin@xdin.com>
> +L:     netdev@vger.kernel.org
> +S:     Maintained
> +F:     net/hsr/*

Using
F:	net/hsr/

will allow any subdirectories to also be under
the same "Maintained" block.

> This would indicate that people should CC me when they send patches or find bugs, 
> and that I should review the patch within a couple of weeks and get back to the
> sender and the list with my comments, right? Just making sure I understand what 
> would be expected of me.
> 
> And where should the MAINTAINERS patch go - to netdev or to lkml?

I think netdev with lkml cc'd.
