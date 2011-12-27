From: Rahul Kumar <mailforgroup@gmail.com>
Subject: ipip6_tunnel_xmit
Date: Mon, 26 Dec 2011 22:48:41 -0500
Message-ID: <CACLebovyJhHMV5Nz+rEtm0sj7QeXcjXz8-D+bfTQx70x8+nsJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:44122 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752824Ab1L0Dsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 22:48:42 -0500
Received: by vcbfk14 with SMTP id fk14so8720773vcb.19
        for <netdev@vger.kernel.org>; Mon, 26 Dec 2011 19:48:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm trying to understand the sit driver code net/ipv6/sit.c
(2.6.35.12). I'm trying to forward incoming packet from another
interface (eth0) to ISATAP tunnel interface (is0) by calling
dev_queue_xmit (dev) with dev set to is0. Eventually ipip6_tunnel_xmit
routine is getting called, skb_dst()->neighbor is returning null. (I
think this is returning null since the dest ip(v6) is incorrectly
set). I would like to know what should be the header fields that needs
to be set when passing down to tunnel, in order to forward it to
isatap router. Please let me know
