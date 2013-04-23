From: Masatake YAMATO <yamato@redhat.com>
Subject: Re: [PATCH 1/2] genetlink: trigger BUG_ON if a group name is too
 long
Date: Tue, 23 Apr 2013 18:27:38 +0900 (JST)
Message-ID: <20130423.182738.1215875866444074225.yamato@redhat.com>
References: <1363693648-10015-1-git-send-email-yamato@redhat.com>
	<1363693648-10015-2-git-send-email-yamato@redhat.com>
	<20130320.120705.58997943737455552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24449 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756110Ab3DWJ1n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Apr 2013 05:27:43 -0400
In-Reply-To: <20130320.120705.58997943737455552.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] genetlink: trigger BUG_ON if a group name is too long
Date: Wed, 20 Mar 2013 12:07:05 -0400 (EDT)
> From: Masatake YAMATO <yamato@redhat.com>
> Date: Tue, 19 Mar 2013 20:47:27 +0900
> 
>> Trigger BUG_ON if a group name is longer than GENL_NAMSIZ.
>> 
>> Signed-off-by: Masatake YAMATO <yamato@redhat.com>
> 
> Applied, thanks.
> 
> Although I'm disappointed that the compiler doesn't say anything about
> this in the assignment.
> 
> We're assigning "char[16] = STRING" and it doesn't say anything if the
> final NULL char doesn't fit into the array.

Now sparse with -Winit-cstring option can detect this kind assignment.

https://git.kernel.org/cgit/devel/sparse/chrisl/sparse.git/commit/?id=c3430e57bc57ff40d5ce95ef2d26b8d70346f58f

Masatake YAMATO
