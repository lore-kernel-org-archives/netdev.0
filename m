From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [RFC][PATCH 1/3] enic: add Makefile, patch Kconfg, MAINTAINERS,
 etc
Date: Tue, 26 Aug 2008 10:53:26 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0808261044120.11710@palito_client100.nuovasystems.com>
References: <adaiqtolo2i.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuova-ex1.nuovasystems.com ([67.91.200.196]:44512 "EHLO
	nuova-ex1.nuovasystems.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758035AbYHZSBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 14:01:38 -0400
In-Reply-To: <adaiqtolo2i.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Aug 2008, Roland Dreier wrote:

> > +config ENIC
> > +	tristate "Cisco 10Gigabit Ethernet NIC"
>
> The Kconfig file seems to use "10 Gigabit Ethernet" (with a space) or
> variations on "10Gb Ethernet".  Probably worth it not to add yet another
> variation.

done

> > +	depends on PCI
> > +	select INET_LRO
>
> I believe if you select INET_LRO, you'd better depend on INET or else it
> is possible to create unbuildable configs.
>

done
