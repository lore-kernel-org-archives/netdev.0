From: Naohiro Ooiwa <nooiwa@miraclelinux.com>
Subject: Why doesn't RAW use daddr_cache ?
Date: Tue, 15 Jul 2008 10:58:59 +0900
Message-ID: <487C0463.8070705@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, nicolas.dichtel@6wind.com,
	usagi-users@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:19027 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753916AbYGOB7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 21:59:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I have a question about "daddr_cache" in IPv6.

UDP socket uses daddr_cache via p6_sk_dst_lookup()/ip6_dst_store().
But, RAW socket has stopped using it.

I'm afraid of performance degrade in RAW.
Could you please tell me why "daddr_cache" is
deleted in RAW?

Note:
  It's deleted by the following patch.
  commit 6d3e85ecf22a5e3610df47b9c3fb2fc32cfd35bf
  commit 497c615abad7ee81994dd592194535aea2aad617

Regards,
Naohiro Ooiwa

