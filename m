From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net v2] bonding: Fix ARP monitor validation
Date: Sun, 07 Feb 2016 22:03:50 -0800
Message-ID: <19637.1454911430@famine>
References: <29855.1454448956@famine> <20160207.142645.2230058287676177228.davem@davemloft.net>
Cc: netdev@vger.kernel.org, vfalico@gmail.com,
	gospo@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:47413 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbcBHGDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 01:03:55 -0500
In-reply-to: <20160207.142645.2230058287676177228.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David Miller <davem@davemloft.net> wrote:
[...]
>> 	This patch changes the logic in bond_arp_rcv to additionally
>> accept an ARP reply for validation on any slave if there is a current ARP
>> slave and it sent an ARP probe during the previous arp_interval.
>> 
>> Fixes: aeea64ac717a ("bonding: don't trust arp requests unless active slave really works")
>> Cc: Veaceslav Falico <vfalico@gmail.com>
>> Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
>> Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>
>
>I'm going to wait until we get some feedback from Uwe if you don't mind
>Jay, it would be nice to know if it solves their problem too.

	Sounds good to me.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
