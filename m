From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rtnetlink: NUL-terminate IFLA_PHYS_PORT_NAME string
Date: Thu, 04 May 2017 11:24:42 -0400 (EDT)
Message-ID: <20170504.112442.1701097085035128140.davem@davemloft.net>
References: <20170504144858.1905-1-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thaller@redhat.com, dsahern@gmail.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56070 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753182AbdEDPYo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 11:24:44 -0400
In-Reply-To: <20170504144858.1905-1-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Thu,  4 May 2017 16:48:58 +0200

> IFLA_PHYS_PORT_NAME is a string attribute, so terminate it with \0.
> Otherwise libnl3 fails to validate netlink messages with this attribute.
> "ip -detail a" assumes too that the attribute is NUL-terminated when
> printing it. It often was, due to padding.
> 
> I noticed this as libvirtd failing to start on a system with sfc driver
> after upgrading it to Linux 4.11, i.e. when sfc added support for
> phys_port_name.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Good catch, applied and queued up for -stable, thanks.
