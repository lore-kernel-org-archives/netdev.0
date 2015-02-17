From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH]     iproute2: Extend ip address command to enable
 multicast group join/leave on IP level.
Date: Tue, 17 Feb 2015 11:34:18 -0500
Message-ID: <20150217113418.2811716d@uryu.home.lan>
References: <1424125415-4616-1-git-send-email-challa@noironetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Madhu Challa <challa@noironetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:36325 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751598AbbBQQeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 11:34:22 -0500
Received: by mail-qg0-f49.google.com with SMTP id q107so28646469qgd.8
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2015 08:34:21 -0800 (PST)
In-Reply-To: <1424125415-4616-1-git-send-email-challa@noironetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Feb 2015 14:23:35 -0800
Madhu Challa <challa@noironetworks.com> wrote:

>     Joining multicast group on ethernet level via "ip maddr" command would
>     not work if we have an Ethernet switch that does igmp snooping since
>     the switch would not replicate multicast packets on ports that did not
>     have IGMP reports for the multicast addresses.
> 
>     Linux vxlan interfaces created via "ip link add vxlan" have the group option
>     that enables then to do the required join.
> 
>     By extending ip address command with option "autojoin" we can get similar
>     functionality for openvswitch vxlan interfaces as well as other tunneling
>     mechanisms that need to receive multicast traffic. The kernel code is
>     structured similar to how the vxlan driver does a group join / leave.
> 
>     example:
>     ip address add 224.1.1.10/24 dev eth5 autojoin
>     ip address del 224.1.1.10/24 dev eth5
> 
> Signed-off-by: Madhu Challa <challa@noironetworks.com>

You need to get MCAUTOJOIN into net-next first.
