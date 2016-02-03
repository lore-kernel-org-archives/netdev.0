From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net v2] bonding: Fix ARP monitor validation
Date: Wed, 03 Feb 2016 12:23:37 -0800
Message-ID: <9034.1454531017@famine>
References: <29855.1454448956@famine> <20160203194058.GE54057@redhat.com>
Cc: netdev@vger.kernel.org, Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Uwe Koziolek <uwe.koziolek@redknee.com>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:45758 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754605AbcBCUXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 15:23:44 -0500
In-reply-to: <20160203194058.GE54057@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jarod Wilson <jarod@redhat.com> wrote:
[...]
>This sounds suspiciously like the same problem Uwe was encountering[*] and
>attempting to solve. Uwe, can you give this patch a try?
>
>[*] = http://marc.info/?l=linux-netdev&m=144416122705850&w=2

	Agreed; my apologies for not Cc'ing you, Uwe.

	FWIW, the "Sometimes, the issue sorts itself out after a while"
Uwe reported is likely due to something causing a switch flood (TCN or
clearing of the MAC table); in that case, the ARP reply is sent to all
ports, so the "expected" curr_arp_slave receives the ARP reply.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
