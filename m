From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Find vlanid with non-root user
Date: Tue, 13 Aug 2013 14:46:57 -0700
Message-ID: <20130813144657.361b31b5@nehalam.linuxnetplumber.net>
References: <CAEFY+qzCQqEpLjjM1iBjtHmDh70ktpx+GCHgTuCceu1A53-1Tw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Amador Pahim <amador@pahim.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:33309 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265Ab3HMVrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 17:47:01 -0400
Received: by mail-pb0-f44.google.com with SMTP id xa7so8396379pbc.31
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 14:47:00 -0700 (PDT)
In-Reply-To: <CAEFY+qzCQqEpLjjM1iBjtHmDh70ktpx+GCHgTuCceu1A53-1Tw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Aug 2013 17:46:45 -0300
Amador Pahim <amador@pahim.org> wrote:

> Hello,
> 
> Is there a way to get vlanid from a vlan interface as a regular user?
> Default permissions to /proc/net/vlan/ is 600.
> -rw-------. 1 root root 0 Aug 13 17:23 /proc/net/vlan/eth1.10-fcoe

ip command will work as non-root user and show vlan (with -d)

$ ip -d li show dev eth0vlan
13: eth0vlan@eth0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT 
    link/ether 10:bf:48:84:6f:5a brd ff:ff:ff:ff:ff:ff
    vlan id 10 <REORDER_HDR>



> Not sure if deducting vlanid from vlan name is a reasonable way to do so.

No. Vlan can be made with any name.

# ip li add link eth0 name eth0vlan type vlan id 10

> Thank you in advance,.
> 
> Best Regards,
