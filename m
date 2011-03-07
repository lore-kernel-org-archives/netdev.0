From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 4/8] bonding: wrap slave state work
Date: Mon, 7 Mar 2011 10:58:40 +0100
Message-ID: <20110307095839.GC2832@psychotron.brq.redhat.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com>
 <1299320969-7951-5-git-send-email-jpirko@redhat.com>
 <4D7254E9.6090605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9182 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755601Ab1CGJ7Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 04:59:24 -0500
Content-Disposition: inline
In-Reply-To: <4D7254E9.6090605@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>>+static inline void bond_set_active_slave(struct slave *slave)
>>+{
>>+	slave->backup = 0;
>
>In the comment above, you said that the possible value for backup
>corresponds with BOND_STATE_ACTIVE and BOND_STATE_BACKUP.
>
>So, should be:
>
>slave->backup = BOND_STATE_ACTIVE;
>
>>+}
>>+
>>+static inline void bond_set_backup_slave(struct slave *slave)
>>+{
>>+	slave->backup = 1;
>
>slave->backup = BOND_STATE_BACKUP;
>

Well, I think it's weird and misleading to assign some define to :1
bitfield. Should be 0 or 1, nothing else.
