From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] Make nicer CONFIG_NET_NS=n case code
Date: Thu, 01 Nov 2007 00:02:38 -0700 (PDT)
Message-ID: <20071101.000238.239270625.davem@davemloft.net>
References: <4729047B.3080003@cosmosbay.com>
	<m1wst2hjo5.fsf@ebiederm.dsl.xmission.com>
	<47297933.7090609@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, xemul@openvz.org, netdev@vger.kernel.org,
	devel@openvz.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32927
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752343AbXKAHCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 03:02:38 -0400
In-Reply-To: <47297933.7090609@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 01 Nov 2007 07:58:59 +0100

> I agree with you that with current state, this atomic_inc/atomic_dec_and_test 
> wont come in profiles unless a trivial bench is writen
> 
> for(;;){close(socket(....));}

Just add one packet send and one packet receive in there and you have
a transaction workload.  It's really not that unrealistic.
