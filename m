From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Wed, 8 Aug 2012 09:04:55 +0300
Message-ID: <CAJZOPZ+W0wfa38LejXt0gvBNa8Q6pWVZOs7xctHGRQXHAeMYPQ@mail.gmail.com>
References: <501C3527.6060809@mellanox.com>
	<20120803.143315.151094375569109262.davem@davemloft.net>
	<501C5328.4060301@mellanox.com>
	<20120803.163627.1867181085116225405.davem@davemloft.net>
	<50205DE0.7080706@mellanox.com>
	<87obmnfs4p.fsf@xmission.com>
	<871ujjfkb1.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ali Ayoub <ali@mellanox.com>, David Miller <davem@davemloft.net>,
	ogerlitz@mellanox.com, roland@kernel.org, netdev@vger.kernel.org,
	sean.hefty@intel.com, erezsh@mellanox.co.il, dledford@redhat.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:37613 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415Ab2HHGE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 02:04:56 -0400
Received: by yenl2 with SMTP id l2so411024yen.19
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2012 23:04:55 -0700 (PDT)
In-Reply-To: <871ujjfkb1.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman <ebiederm@xmission.com> wrote:
>> Ali Ayoub <ali@mellanox.com> writes:

>> Among other things, the main benefit we're targeting is to allow IPoE
>> traffic within the VM to go through the (Ethernet) vBridge down to the
>> eIPoIB PIF, and eventually to IPoIB and to the IB network.

> Oh yes.  It just occurred to me there is huge problem with eIPoIB as
> currently presented in these patches.  It breaks DHCPv4 the same way
> it breaks ARP, but DHCPv4 is not fixed up.

To put things in place, DHCPv4 is supported with eIPoIB, the DHCP
UDP/IP payload  isn't touched, only need to set the BOOTP broadcast
flag in the dhcp server config file.

Or.
