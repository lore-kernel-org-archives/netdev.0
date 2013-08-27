From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] ipv4: IP_TOS and IP_TTL can be
 specified as ancillary data
Date: Tue, 27 Aug 2013 14:56:49 -0400 (EDT)
Message-ID: <20130827.145649.1682045616049011855.davem@davemloft.net>
References: <cover.1377257704.git.ffusco@redhat.com>
	<cover.1377257704.git.ffusco@redhat.com>
	<aaa7e0af2fe535ea5216e438b5f65db88dcef8b2.1377257704.git.ffusco@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ffusco@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58429 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753298Ab3H0S4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 14:56:52 -0400
In-Reply-To: <aaa7e0af2fe535ea5216e438b5f65db88dcef8b2.1377257704.git.ffusco@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francesco Fusco <ffusco@redhat.com>
Date: Fri, 23 Aug 2013 14:19:32 +0200

>   - changed the icmp_cookie ttl field from __s16 to __u8.
>     A value of 0 means that the TTL has not been specified

Sorry, I have to ask you to change the ttl field type back to __s16
and use "-1" to mean not-specified.

Zero is a valid TTL setting and it means to not allow the
packet to leave this host.

Please make this change and resubmit, thanks.
