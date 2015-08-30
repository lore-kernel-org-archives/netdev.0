From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 net-next 4/4] vxlan: do not receive IPv4 packets on
 IPv6 socket
Date: Sun, 30 Aug 2015 11:30:45 +0200
Message-ID: <20150830093045.GA6393@pox.localdomain>
References: <cover.1440787600.git.jbenc@redhat.com>
 <823880925bf39790189708fcb7f7158f21231237.1440787601.git.jbenc@redhat.com>
 <20150828223929.GC32001@pox.localdomain>
 <20150829105544.33b7799f@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Pravin Shelar <pshelar@nicira.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:34621 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706AbbH3Jas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2015 05:30:48 -0400
Received: by wizs10 with SMTP id s10so4014417wiz.1
        for <netdev@vger.kernel.org>; Sun, 30 Aug 2015 02:30:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150829105544.33b7799f@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/29/15 at 10:55am, Jiri Benc wrote:
> On Sat, 29 Aug 2015 00:39:29 +0200, Thomas Graf wrote:
> > Can we fix VXLAN instead? It should be possible to receive and send both
> > v4 and v6 frames and represent it with metadata on a single socket.
> 
> That's actually what I intend to do next. But I need the flag and this
> patch for that. If IPv6 is enabled, I'll open two sockets within a
> single vxlan_sock for metadata based vxlan, IPv4 one and IPv6 one. It
> would be easier to just open an IPv6 socket and receive both IPv4 and
> IPv6 traffic through it but unfortunately, this depends on bindv6only
> sysctl. We don't want to have IPv4 vxlan broken if bindv6only is set.
> Therefore, we need two sockets, and the IPv6 one needs to be v6only.

Awesome, sounds great.
