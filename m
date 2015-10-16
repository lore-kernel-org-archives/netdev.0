From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] overflow-arith: begin to add support for
 overflow builtin functions
Date: Fri, 16 Oct 2015 01:04:35 -0700 (PDT)
Message-ID: <20151016.010435.1672557925275296954.davem@davemloft.net>
References: <1444910825-25021-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51965 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752426AbbJPHs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 03:48:26 -0400
In-Reply-To: <1444910825-25021-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 15 Oct 2015 14:07:04 +0200

> The idea of the overflow-arith.h header is to collect overflow checking
> functions in one central place.
> 
> If gcc compiler supports the __builtin_overflow_* builtins we use them
> because they might give better performance, otherwise the code falls
> back to normal overflow checking functions.
> 
> The builtin_overflow functions are supported by gcc-5 and clang. The
> matter of supporting clang is to just provide a corresponding
> CC_HAVE_BUILTIN_OVERFLOW, because the specific overflow checking builtins
> don't differ between gcc and clang.
> 
> I just provide overflow_usub function here as I intend this to get merged
> into net, more functions will definitely follow as they are needed.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

I think a global helper interface like this should get a review on
linux-kernel, so please at least let it get some exposure there
first.

You can ask whether it's OK to merge it via my tree since that'll
have the first user.

Thanks.
