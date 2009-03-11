From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 0/4] qlge: More bug fixes.
Date: Wed, 11 Mar 2009 14:55:39 -0700
Message-ID: <1236808543-11165-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:2059 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754970AbZCKV7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 17:59:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Attached are relevant bugfixes backported from the net-next changes I
did this week. I mentioned that I would drop netif_set_gso_max_size()
from net-next per your request.  I just wanted to get these out of the
way first...

Regards,
Ron Mercer

qlge: bugfix: Pad outbound frames smaller than 60 bytes.

	With some asic configurations xmit of frames smaller than 60
	bytes may fail.

qlge: bugfix: Move netif_napi_del() to common call point.

	Moving netif_napi_del() up the call chain so it
	will get called from all exit points.

qlge: bugfix: Tell hw to strip vlan header.


qlge: bugfix: Increase filter on inbound csum.

	Chip does not do UDP checksum when fragmentation occurs.



