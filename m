From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [net-next-2.6 PATCH] ipoib: remove addrlen check for mc addresses
Date: Mon, 22 Mar 2010 18:26:14 +0100
Message-ID: <20100322172613.GA2884@psychotron.redhat.com>
References: <20100322132138.GC2780@psychotron.lab.eng.brq.redhat.com>
 <20100322165916.GE29129@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, ogerlitz@voltaire.com,
	linux-rdma@vger.kernel.org, monis@voltaire.com
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43454 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754962Ab0CVR0Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Mar 2010 13:26:25 -0400
Content-Disposition: inline
In-Reply-To: <20100322165916.GE29129@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 22, 2010 at 05:59:16PM CET, jgunthorpe@obsidianresearch.com wrote:
>On Mon, Mar 22, 2010 at 02:21:39PM +0100, Jiri Pirko wrote:
>> Finally this bit can be removed. Currently, after the bonding driver is
>> changed/fixed (32a806c194ea112cfab00f558482dd97bee5e44e net-next-2.6),
>> that's not possible for an addr with different length than dev->addr_len
>> to be present in list. Removing this check as in new mc_list there will be
>> no addrlen in the record.
>
>Maybe just make this check a WARN_ON?

As I said, addrlen will no longer be in record (because it would have no
meaning since length ot the addr is always dev->addr_len)

>Can userspace create a mc_list
>entry with the wrong size via netlink?

Nope - this is not possible. dev->addr_len is used.

>
>Jason
