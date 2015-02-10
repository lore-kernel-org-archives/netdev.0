From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: udp v6 early demux?
Date: Tue, 10 Feb 2015 09:32:35 -0800
Message-ID: <1423589555.28434.36.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54DA3C64.1060309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:59937 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421AbbBJRcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 12:32:41 -0500
Received: by mail-pa0-f43.google.com with SMTP id fa1so27566130pad.2
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 09:32:40 -0800 (PST)
In-Reply-To: <54DA3C64.1060309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-02-10 at 12:14 -0500, Vlad Yasevich wrote:
> Hi
> 
> While testing udpv6 lockless path, I noticed that there is no
> support for udpv6 early demux?  Is there a technical reason why,
> or was this just something that got forgotten (kind of like
> lockeless sendmsg)?

If you have a use case for connected UDP ipv6 flows with performance
issues, then you might add early demux I guess.

IPv4 udp early demux has been a bit of a hack actually,
as Shawn main usage was multicast AFAIK

63c6f81cdde5 udp: ipv4: do not waste time in __udp4_lib_mcast_demux_lookup
610438b74496 udp: ipv4: fix potential use after free in udp_v4_early_demux()
f69b923a758f udp: fix a typo in __udp4_lib_mcast_demux_lookup
421b3885bf6d udp: ipv4: Add udp early demux
