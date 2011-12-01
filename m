From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ipv4: broadcast sometimes leaves wrong interface (since commit
 e066008b38ca9ace1b6de8dbbac8ed460640791d)
Date: Thu, 1 Dec 2011 23:00:27 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1112012252270.1634@ja.ssi.bg>
References: <1322585087.25018.115.camel@icts-sp-039>  <alpine.LFD.2.00.1111300010150.2020@ja.ssi.bg>  <20111129.182333.365445684859306013.davem@davemloft.net>  <alpine.LFD.2.00.1111300148400.2328@ja.ssi.bg> <1322756728.12482.52.camel@icts-sp-039>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jeroen van Ingen <jeroen@zijndomein.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:54150 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753453Ab1LAU7n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Dec 2011 15:59:43 -0500
In-Reply-To: <1322756728.12482.52.camel@icts-sp-039>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 1 Dec 2011, Jeroen van Ingen wrote:

> FYI: we successfully tested two scenarios that provide a workaround with
> the current kernel versions:
> 
> 1) Explicitly configuring Radius to use one of the secondary IPs as
> source for the DHCP broadcast. Since the IP we chose is only bound to
> eth0, this broadcast goes out the correct interface. Other
> system-generated broadcast would probably still go out the wrong
> interface, but at least it allows us to accept more than one PPTP
> client.
> 
> 2) Adding an option to the "pppd" config, so the ppp-devices it creates
> do not use the primary IP from eth0 but rather one of the secondary
> addresses. This way we don't have to modify any other software that
> might generate a broadcast.
> 
> 
> While the second option provides a workable solution for us, we're still
> under the impression that this change in behavior might cause a problem
> for other users and/or configurations as well. We'll leave the rest of
> the considerations to the real experts, while remaining curious about
> the outcome :)

	Yes, thanks for confirming that this is the actual
problem! I hope David will find the best way to restore
this feature.

> Thanks again for your assistance.
> 
> 
> Regards,
> 
> Jeroen van Ingen
> ICT Service Centre
> University of Twente, P.O.Box 217, 7500 AE Enschede, The Netherlands

Regards

--
Julian Anastasov <ja@ssi.bg>
