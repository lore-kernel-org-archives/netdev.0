From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: ipv6: put autoconf routes into
 per-interface tables
Date: Sat, 7 Jan 2017 21:24:18 -0700
Message-ID: <37df3b18-d17b-5875-7b44-db40be7b459c@cumulusnetworks.com>
References: <20170106153026.24785-1-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: zenczykowski@gmail.com, hannes@stressinduktion.org, ek@google.com,
        hideaki.yoshifuji@miraclelinux.com, davem@davemloft.net,
        drosen@google.com
To: Lorenzo Colitti <lorenzo@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:34793 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933204AbdAHEYZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 23:24:25 -0500
Received: by mail-pg0-f52.google.com with SMTP id 14so19776901pgg.1
        for <netdev@vger.kernel.org>; Sat, 07 Jan 2017 20:24:25 -0800 (PST)
In-Reply-To: <20170106153026.24785-1-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/6/17 8:30 AM, Lorenzo Colitti wrote:
> This patch adds a per-interface sysctl to have the kernel put
> autoconf routes into different tables. This allows each interface
> to have its own routing table if desired.  Choosing the default
> interface, or using different interfaces at the same time on a
> per-socket or per-packet basis) can be done using policy routing
> mechanisms that use as SO_BINDTODEVICE / IPV6_PKTINFO, mark-based
> routing, or UID-based routing to select specific routing tables.

Why not use the VRF capability then? create a VRF and assign the interface to it. End result is the same -- separate tables and the need to use a bind-to-device API to hit those routes.
