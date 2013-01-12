From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: [RFC PATCH 6/6] ipv6: IPv6 over IEEE1394 (RFC3146) support.
Date: Sat, 12 Jan 2013 17:44:15 +0100
Message-ID: <50F192DF.9090100@gmail.com>
References: <50F17178.3090705@linux-ipv6.org> <20130112164741.1a0ab7bb@stein> <50F191CF.3060803@linux-ipv6.org>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>, netdev@vger.kernel.org,
	linux1394-devel@lists.sourceforge.net
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:33341 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752374Ab3ALQoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 11:44:18 -0500
Received: by mail-ea0-f179.google.com with SMTP id i12so1093061eaa.24
        for <netdev@vger.kernel.org>; Sat, 12 Jan 2013 08:44:17 -0800 (PST)
In-Reply-To: <50F191CF.3060803@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> How about putting EUI64, maxrec, sspd and fifo in dev->dev_addr?
> This enable us to send NDISC/ARP packet easily (based on neighbor
> cache entry), and driver can be notified for new neighbors (thus
> new peers).
Hm, that looks a bit strange to me, because we need that only for link 
layer option packets and not for every IPv6 packet transmitted via firewire.
