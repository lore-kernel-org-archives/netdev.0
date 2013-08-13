From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sctp: sctp_assoc_control_transport: fix MTU
 size in SCTP_PF state
Date: Mon, 12 Aug 2013 22:12:52 -0700 (PDT)
Message-ID: <20130812.221252.2248587650673854871.davem@davemloft.net>
References: <1376053748-31783-1-git-send-email-dborkman@redhat.com>
	<5204F121.7080609@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, kheiss@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, nhorman@tuxdriver.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34306 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752889Ab3HMFMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 01:12:53 -0400
In-Reply-To: <5204F121.7080609@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Fri, 09 Aug 2013 09:39:45 -0400

> On 08/09/2013 09:09 AM, Daniel Borkmann wrote:
>> The SCTP Quick failover draft [1] section 5.1, point 5 says that the
>> cwnd
>> should be 1 MTU. So, instead of 1, set it to 1 MTU.
>>
>>    [1] https://tools.ietf.org/html/draft-nishida-tsvwg-sctp-failover-05
>>
>> Reported-by: Karl Heiss <kheiss@gmail.com>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> Cc: Neil Horman <nhorman@tuxdriver.com>
 ...
> Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Applied, thanks.
