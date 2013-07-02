From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tools: selftests: psock_tpacket: get rid of
 macro wrappers
Date: Tue, 02 Jul 2013 00:24:14 -0700 (PDT)
Message-ID: <20130702.002414.423567437565465345.davem@davemloft.net>
References: <1372694990-10876-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47948 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932219Ab3GBHYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 03:24:15 -0400
In-Reply-To: <1372694990-10876-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon,  1 Jul 2013 18:09:50 +0200

> The TPACKET_V3 test code consists of a lot of unecessary macro
> wrappers that rather obfuscate what members are accessed in what
> way. So get rid of them and make the code more readable. Also
> credit Chetan for providing tpacket_v3 example code. Furthermore,
> get rid of private offset usage, as we do not need it here.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
