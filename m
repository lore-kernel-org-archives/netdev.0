From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] tcp: use RFC6298 compliant TCP RTO
 calculation
Date: Fri, 17 Jun 2016 11:32:35 -0700 (PDT)
Message-ID: <20160617.113235.1099766688971255047.davem@davemloft.net>
References: <CAK6E8=eeso8OEN_0-znqkuEyVTqzP1mTvwktk4QOsrLJXmuj9Q@mail.gmail.com>
	<20160615180003.28970-1-dmetz@mytum.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel.Metz@rohde-schwarz.com,
	hagen@jauu.net, edumazet@google.com, ycheng@google.com
To: dmetz@mytum.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52323 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752021AbcFQSci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 14:32:38 -0400
In-Reply-To: <20160615180003.28970-1-dmetz@mytum.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Metz <dmetz@mytum.de>
Date: Wed, 15 Jun 2016 20:00:03 +0200

> This patch adjusts Linux RTO calculation to be RFC6298 Standard
> compliant. MinRTO is no longer added to the computed RTO, RTO damping
> and overestimation are decreased.
 ...

Yuchung, I assume I am waiting for you to do the testing you said
you would do for this patch, right?
