From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH 17/11]Optimize the upload speed for PPP connection.
Date: Tue, 17 Nov 2009 05:20:09 -0500
Message-ID: <4B0278D9.6030806@gmail.com>
References: <faf197be196ee.196eefaf197be@huawei.com> <20091117.012248.86306050.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: huananhu@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f202.google.com ([209.85.211.202]:63673 "EHLO
	mail-yw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753150AbZKQKUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 05:20:17 -0500
In-Reply-To: <20091117.012248.86306050.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Your patch is broken, please don't wate my time like this.
> 
> + git apply --check --whitespace=error-all diff
> error: patch failed: drivers/net/ppp_async.c:36
> error: drivers/net/ppp_async.c: patch does not apply
> 
What David may have meant, had he followed Documentation/ManagementStyle
or had any project management skills what-so-ever, is that you need to
follow Documentation/SubmittingPatches more carefully.

Look at 15) The canonical patch format

[PATCH 17/11] makes no sense, you don't have 11 patches, and the 17th
patch of 11 can never exist.

Need a better "subsystem: summary phrase", perhaps
   "net: PPP buffer too small for higher speed connections"

A marker line containing simply "---".

And your trailer boilerplate badly breaks the system, because it's
missing the SMTP email standard "--" line in front of it.

You'll get nicer formatting with 'git format-patch -o ~ HEAD~1' after you
do a 'git commit -a' on your git tree.

It takes some time, even for a simple 1 line fix like this....

Hope that helps.
