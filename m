From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/5] ipv6: cleanup after rt6_genid removal
Date: Tue, 07 Oct 2014 00:03:37 -0400 (EDT)
Message-ID: <20141007.000337.1923110318110453432.davem@davemloft.net>
References: <cover.1412618014.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hideaki@yoshifuji.org, kafai@fb.com,
	cwang@twopensource.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40828 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbaJGEDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 00:03:38 -0400
In-Reply-To: <cover.1412618014.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon,  6 Oct 2014 19:58:33 +0200

> Leftover patches after rt6_genid removal after 705f1c869d577c ("ipv6:
> remove rt6i_genid").
> 
> Major two changes are:
> * keep fib6_sernum per namespace to reduce number of flushes in case
>   system has high number of namespaces
> * make fn_sernum updates cheaper
> 
> v2: Incorporated feedback from Cong Wang, thanks a lot!

Series applied, thanks.
