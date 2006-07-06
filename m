From: Dawid Ciezarkiewicz <dpc@asn.pl>
Subject: Re: [PATCH][ebtables][vlan] ebt_vlan_t target
Date: Thu, 6 Jul 2006 13:34:40 +0200
Message-ID: <200607061334.41012.dpc@asn.pl>
References: <200607052149.16473.dpc@asn.pl> <200607061315.17109.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from apollo.asn.pl ([85.14.104.1]:32946 "HELO apollo.asn.pl")
	by vger.kernel.org with SMTP id S965171AbWGFLei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2006 07:34:38 -0400
To: netdev@vger.kernel.org
In-Reply-To: <200607061315.17109.netdev@axxeo.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, 6 July 2006 13:15, Ingo Oeser wrote:
> First of all: 
> 	You should not implemented "--vlan-target". 
> 	Always return EBT_CONTINUE. That saves a lot of (duplicated) code
> 	(you can express the same using some more rules) while keeping 
> 	the same flexibility level. Rules for transforming/mangling 
> 	and decision rules should be seperate.

OK. I've been doing everything looking how ebt_mark.c is written. I thought about dropping 
it (iptables has nothing like this and works), but I havent't been sure if I should.

> > diff -Nur linux-2.6.17.orig/net/bridge/netfilter/Kconfig 
> > linux-2.6.17/net/bridge/netfilter/Kconfig
> > --- linux-2.6.17.orig/net/bridge/netfilter/Kconfig	2006-06-18 
> > 03:49:35.000000000 +0200
> > +++ linux-2.6.17/net/bridge/netfilter/Kconfig	2006-06-28 20:48:27.000000000 
> > +0200
> > @@ -165,6 +165,15 @@
> > 
> >  	  To compile it as a module, choose M here.  If unsure, say N.
> > 
> > +config BRIDGE_EBT_VLAN_T
> > +	tristate "ebt: vlan target support"
> > +	depends on BRIDGE_NF_EBTABLES
> > +	help
> > +	  This option adds the vlan target.
> > +
> > +	  To compile it as a module, choose M here.  If unsure, say N.
> > +
> > +
> 
> Please put your nice explanations "to change vlan ids in fly" from your email here.

OK.

> I cannot comment on rest of the patch and hope other people will do :-)

I hope they do, too. Thanks. :)
