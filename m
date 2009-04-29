From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.29.1: unregister_netdevice problem
Date: Wed, 29 Apr 2009 11:08:09 +0200
Message-ID: <20090429090809.GA2995@ami.dom.local>
References: <20090422055735.GA4334@night.netis.ru> <20090427054103.GA27529@night.netis.ru> <20090428125755.GA5242@night.netis.ru> <49F76BF6.4040709@gmail.com> <20090429054510.GA8267@night.netis.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Alexander V. Lukyanov" <lav@netis.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f163.google.com ([209.85.218.163]:50851 "EHLO
	mail-bw0-f163.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759166AbZD2JKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 05:10:13 -0400
Content-Disposition: inline
In-Reply-To: <20090429054510.GA8267@night.netis.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 29, 2009 at 09:45:10AM +0400, Alexander V. Lukyanov wrote:
> On Tue, Apr 28, 2009 at 10:49:58PM +0200, Jarek Poplawski wrote:
> > Do you mean if you wait a bit longer (until the first one is really removed)
> 
> The problem is that it is never removed. I waited for at least 30 minutes.
> 
> > before running another one, it doesn't s(t)uck? Is there a change e.g. wrt.
> > 2.6.28?
> 
> I mean, 'vconfig rem' on another interface stucks if the previous vconfig
> has not finished, and it never finishes. So I cannot check if other vlan
> interfaces have the same 'refcnt' problem. So far I tried 'vconfig rem' on
> two vlan interfaces and I have a dozen.
> 
> Again, the problem only happens after I notice surprisingly high LA (30
> instead of 2-6) and interactive slowness. When it happens, I check network
> usage, disk usage, cpu usage, mem usage - they are normal or even lower than
> usual.
> 
> The server is running transparent squid and named. The last kernel version
> was 2.6.27.21 and it did not have this problem.

So looks like a regression. Alas this thing could be hard to debug and
still more data is needed. For the beginning maybe: .config, dmesg,
and a few SysRq logs while this happens e.g. Alt-PrtScr with t, d, w, q
(gzipped or as attachments to a bugzilla report). (If it's not a big
problem trying 2.6.28.9 could be helpful too.)

Thanks,
Jarek P.
