From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iproute2-3.6.0 assumes presence of iptables
Date: Wed, 3 Oct 2012 08:53:35 -0700
Message-ID: <20121003085335.67ef66da@nehalam.linuxnetplumber.net>
References: <1349200892.11088.4.camel@kyoto.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matt Burgess <matthew@linuxfromscratch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36399 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932427Ab2JCPyM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2012 11:54:12 -0400
In-Reply-To: <1349200892.11088.4.camel@kyoto.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 02 Oct 2012 19:01:32 +0100
Matt Burgess <matthew@linuxfromscratch.org> wrote:

> Hi,
> 
> When compiling iproute2-3.6.0 on a host that doesn't have iptables available, I get the following error:
> 
> gcc -Wall -Wstrict-prototypes -O2 -I../include -DRESOLVE_HOSTNAMES
> -DLIBDIR=\"/usr/lib\" -DCONFDIR=\"/etc/iproute2\" -D_GNU_SOURCE
> -DCONFIG_GACT -DCONFIG_GACT_PROB -DYY_NO_INPUT   -c -o em_ipset.o
> em_ipset.c
> em_ipset.c:26:21: fatal error: xtables.h: No such file or directory
> 
> Fixed by the following patch, which guards the building of em_ipset.o on
> the presence of suitable headers.
> 
> Thanks,
> 
> Matt.

Applied
