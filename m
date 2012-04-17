From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 00/12] add namespace support for netfilter protos
Date: Tue, 17 Apr 2012 12:59:00 +0200
Message-ID: <20120417105900.GA2765@1984>
References: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
 <alpine.LNX.2.01.1204171233590.31683@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gao feng <gaofeng@cn.fujitsu.com>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, ebiederm@xmission.com,
	serge.hallyn@canonical.com, dlezcano@fr.ibm.com
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37256 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754297Ab2DQK7H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 06:59:07 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1204171233590.31683@frira.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 17, 2012 at 12:34:48PM +0200, Jan Engelhardt wrote:
> 
> On Tuesday 2012-04-17 04:56, Gao feng wrote:
> 
> >Currently the sysctl of netfilter proto is not isolated, so when 
> >changing proto's sysctl in container will cause the host's sysctl 
> >be changed too. it's not expected.
> 
> I wonder if it made sense to do the configuration of NFCT via
> netlink as well, and deprecate the sysctl interface.

Good point Jan.

However, we're in inconsistent state now and removing interfaces is
not easy / fast.

So I think we have to fix it first and then, if we decide to do so,
deprecate them.

It seems to me like a good idea to target to providing netlink
interfaces for all netfilter tweaks and use iptables (or whatsoever.
command line tool we'll have in the future) to attach specific
configurations to flow.

Thus, having no more sysctl stuff and module parameters tweaks.
