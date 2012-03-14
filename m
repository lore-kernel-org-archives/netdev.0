From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: [PATCH]  fix sierra_net endianess bug
Date: Wed, 14 Mar 2012 16:26:01 +0100
Message-ID: <m2399bmcfq.fsf@igel.home>
References: <4F60A695.4040601@mt.lv>
Mime-Version: 1.0
Content-Type: text/plain
Cc: epasheva@sierrawireless.com, rfiler@sierrawireless.com,
	netdev@vger.kernel.org
To: Maris Paupe <marisp@mt.lv>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:33583 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753531Ab2CNP0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 11:26:05 -0400
In-Reply-To: <4F60A695.4040601@mt.lv> (Maris Paupe's message of "Wed, 14 Mar
	2012 16:09:25 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maris Paupe <marisp@mt.lv> writes:

> I have found that sierra_net does not work properly on big-endian
> systems, it works if bytes are flipped in this particular location.

That should probably be fixed in sierra_net_get_fw_attr (and the author
of sierra_net_get_fw_attr should be hit with a cluestick to not use
kmalloc for allocating a single u16).

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
