From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/2] Avoid in6_addr redefinition
Date: Sun, 3 Jan 2016 15:16:34 -0800
Message-ID: <20160103151634.37e1070e@xeon-e3>
References: <20160103201028.GA4210@nyan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org
To: Felix Janda <felix.janda@posteo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34956 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbcACXQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jan 2016 18:16:25 -0500
Received: by mail-pf0-f181.google.com with SMTP id 78so193770601pfw.2
        for <netdev@vger.kernel.org>; Sun, 03 Jan 2016 15:16:25 -0800 (PST)
In-Reply-To: <20160103201028.GA4210@nyan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 3 Jan 2016 21:10:28 +0100
Felix Janda <felix.janda@posteo.de> wrote:

> On 2015-11-19 22:32:50 GMT Stephen Hemminger <stephen@networkplumber.org> wrote:
> > This header file comes from iptables. Please fix there, otherwise
> > on next time someone does merge from there it will break.
> 
> It is already fixed in iptables:
> 
> https://git.netfilter.org/iptables/commit/include/libiptc/ipt_kernel_headers.h?id=0bb1859e2d6dd79a0a59c3ee65f6a78cba118b86
> 
> Please sync the header with iptables.
> 
> Felix

Ok, I resynced all the iptables headers (into net-next branch).

Compile tested only. I don't use this, it would be good if someone
who actually uses xtables would test.
