From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH] TCPCT+1: initial SYN exchange with SYNACK data
Date: Mon, 05 Oct 2009 04:23:48 -0400
Message-ID: <4AC9AD14.2060500@gmail.com>
References: <4AC79905.1030904@gmail.com>	<20091005.002719.146534039.davem@davemloft.net>	<4AC9A714.7060903@gmail.com> <20091005.010630.214808506.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f199.google.com ([209.85.210.199]:46799 "EHLO
	mail-yx0-f199.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758589AbZJEIY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 04:24:27 -0400
Received: by yxe37 with SMTP id 37so2801425yxe.33
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2009 01:23:50 -0700 (PDT)
In-Reply-To: <20091005.010630.214808506.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> I'm looking at the patch more closely, and as I learn more
> things about your change, my position changes.
> 
>> Perhaps you would prefer this as a config option after all?
> 
> No, then nobody is going to deploy this thing (meaning it really will
> be useless), or everyone will and everyone will enable it and thus eat
> the space.
> 
> It's bad either way.
> 
> Store the data either somewhere else or in an extremely compact form.
> 
More cross-posting, a good thing for responsiveness....

OK, no config option.

This will be widely deployed.  Deployment in DNS root servers is
expected by December.  It will be hammered with 600,000+ queries per
minute.  Does that impact your design expectations?

Tomorrow, I'll send out a new patch with everything buried in a single
kref, the various tests will only be a trifle slower....

