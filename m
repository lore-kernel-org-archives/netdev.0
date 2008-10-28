From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 1/2] udp: introduce struct udp_table and multiple rwlocks
Date: Wed, 29 Oct 2008 00:28:07 +0300
Message-ID: <20081028212807.GA25217@ioremap.net>
References: <20081007160729.60c076c4@speedy> <20081007.135548.56141000.davem@davemloft.net> <48ECBBD8.9060602@cosmosbay.com> <20081008.114527.189056050.davem@davemloft.net> <4907780F.1080808@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, minyard@acm.org, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com, Christoph Lameter <clameter@sgi.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs-studio.ru ([195.178.208.66]:39374 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753429AbYJ1V2L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2008 17:28:11 -0400
Content-Disposition: inline
In-Reply-To: <4907780F.1080808@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Tue, Oct 28, 2008 at 09:37:35PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> Introducing one rwlock per chain reduces latencies, for port
> randomization on heavily loaded UDP servers.
> 
> Some cleanups were done to ease review of following patch.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Ugh-ogh, that's a very cool change!
So far reviewed only this and things look very promising.

-- 
	Evgeniy Polyakov
