From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: sctp: minor: make jsctp_sf_eat_sack
 static
Date: Wed, 13 Feb 2013 14:06:07 -0500 (EST)
Message-ID: <20130213.140607.144614341798606281.davem@davemloft.net>
References: <cover.1360752304.git.dborkman@redhat.com>
	<7eef4b701794c1bb78819bc6e6c45bf99b49801d.1360752304.git.dborkman@redhat.com>
	<20130213.140436.521031425285650154.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43216 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756988Ab3BMTGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 14:06:08 -0500
In-Reply-To: <20130213.140436.521031425285650154.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 13 Feb 2013 14:04:36 -0500 (EST)

> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Wed, 13 Feb 2013 12:03:49 +0100
> 
>> The function jsctp_sf_eat_sack can be made static, no need to extend
>> its visibility.
>> 
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> 
> It's exported for the jprobe lookup by ->symbol_name
> 
> Did you test this?

Never mind, I mis-read this, the symbol name is for the routine being
shadowed by the jprobe, which is exported.

These two patches look fine and I'll apply them, thanks Daniel.
