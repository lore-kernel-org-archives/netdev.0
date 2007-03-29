From: "Gerd v. Egidy" <gerd@egidy.de>
Subject: Re: traffic shaping with NAT: IFB as IMQ replacement?
Date: Fri, 30 Mar 2007 01:08:00 +0200
Message-ID: <200703300108.01994.gerd@egidy.de>
References: <m27it09n5w.fsf@quark.karme-net.hirschau> <1175184716.4881.30.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Jens Thiele <karme@berlios.de>, netdev@vger.kernel.org,
	linuximq@yahoogroups.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from re01.intra2net.com ([82.165.28.202]:1056 "EHLO
	re01.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934361AbXC2XsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 19:48:11 -0400
In-Reply-To: <1175184716.4881.30.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > Linux router:
> > - does NAT for the LANs
> > - runs local processes communicating with the WAN/Internet
>
> I understand this requirement; unfortunately when i polled for features
> majority of people who emailed back were asking for the other things.
> I have changed my opinion a little since last time because the
> netfilter/contracking code now does netlink. I believe this could all be
> achieved in user space. Infact i have started writting some code - the

I'm also interested in shaping NAT. Would you mind telling us what you have in 
mind with your userspace code? Do you plan something like

tun -> your userspace code -> tun
             ^
             | (netlink)
             v
          conntrack

Kind regards,

Gerd
