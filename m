From: Patrick McHardy <kaber@trash.net>
Subject: Re: dead CONFIG_ variables:  net/ipv4/
Date: Thu, 03 May 2007 05:23:03 +0200
Message-ID: <46395597.2000500@trash.net>
References: <Pine.LNX.4.64.0705021711450.16967@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>
To: "Robert P. J. Day" <rpjday@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50987 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767348AbXECDXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 23:23:38 -0400
In-Reply-To: <Pine.LNX.4.64.0705021711450.16967@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert P. J. Day wrote:
>   again, this list contains some CONFIG_ variables that aren't
> technically dead, but *really* should be renamed to not be confused
> with Kconfig variables.  there are, however, legitimately dead ones in
> the following in places:

Please post to netdev for networking related things.

> $ ../dead_config.sh net/ipv4
> ========== IP_NF_NAT ==========
> net/ipv4/netfilter/Kconfig:# If they want FTP, set to $CONFIG_IP_NF_NAT (m or y),
> net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c:#if !defined(CONFIG_IP_NF_NAT) && !defined(CONFIG_IP_NF_NAT_MODULE)
> net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c:#if !defined(CONFIG_IP_NF_NAT) && !defined(CONFIG_IP_NF_NAT_MODULE)

This one is a bug, thanks. Could you post results from the
other net/ subdirectories please?
