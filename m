From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 1/2] openvswitch: Add a missing break
 statement.
Date: Thu, 24 Nov 2016 16:55:33 +0100
Message-ID: <20161124165533.7eaf4b01@griffin>
References: <1479874174-75329-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60222 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966252AbcKXPzh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Nov 2016 10:55:37 -0500
In-Reply-To: <1479874174-75329-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Nov 2016 20:09:33 -0800, Jarno Rajahalme wrote:
> Add a break statement to prevent fall-through from
> OVS_KEY_ATTR_ETHERNET to OVS_KEY_ATTR_TUNNEL.  Without the break
> actions setting ethernet addresses fail to validate with log messages
> complaining about invalid tunnel attributes.
> 
> Fixes: 0a6410fbde ("openvswitch: netlink: support L3 packets")
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>

Acked-by: Jiri Benc <jbenc@redhat.com>

It's a good practice to CC the one who messed up :-) Please do that
next time.

Thanks for noticing the bug and fixing it.

 Jiri
