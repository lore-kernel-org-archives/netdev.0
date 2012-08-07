From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Mon, 06 Aug 2012 20:33:06 -0700
Message-ID: <871ujjfkb1.fsf@xmission.com>
References: <501C3527.6060809@mellanox.com>
	<20120803.143315.151094375569109262.davem@davemloft.net>
	<501C5328.4060301@mellanox.com>
	<20120803.163627.1867181085116225405.davem@davemloft.net>
	<50205DE0.7080706@mellanox.com> <87obmnfs4p.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, ogerlitz@mellanox.com,
	roland@kernel.org, netdev@vger.kernel.org, sean.hefty@intel.com,
	erezsh@mellanox.co.il, dledford@redhat.com
To: Ali Ayoub <ali@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:41590 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757182Ab2HGDdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 23:33:19 -0400
In-Reply-To: <87obmnfs4p.fsf@xmission.com> (Eric W. Biederman's message of
	"Mon, 06 Aug 2012 17:44:06 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ebiederm@xmission.com (Eric W. Biederman) writes:

> Ali Ayoub <ali@mellanox.com> writes:
>
>> Among other things, the main benefit we're targeting is to allow IPoE
>> traffic within the VM to go through the (Ethernet) vBridge down to the
>> eIPoIB PIF, and eventually to IPoIB and to the IB network.

Oh yes.  It just occurred to me there is huge problem with eIPoIB as
currently presented in these patches.  It breaks DHCPv4 the same way
it breaks ARP, but DHCPv4 is not fixed up.

I am stunned to to realize there has been so much push for a solution
that doesn't even support dhcp.

How can anyone possibly argue that eIPoIB works or is useful?  I just
can't imagine.

Totally stunned,
Eric
