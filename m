From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 01/18] netlink: make the check for "send from
 tx_ring" deterministic
Date: Tue, 03 Feb 2015 16:21:02 -0800 (PST)
Message-ID: <20150203.162102.2178616439474613506.davem@davemloft.net>
References: <20150131035513.GK29656@ZenIV.linux.org.uk>
	<1422863977-17668-1-git-send-email-viro@ZenIV.linux.org.uk>
	<54CF7828.6040605@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, netdev@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58146 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754362AbbBDAVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 19:21:02 -0500
In-Reply-To: <54CF7828.6040605@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Mon, 02 Feb 2015 16:14:16 +0300

> On 2/2/2015 10:59 AM, Al Viro wrote:
> 
>> From: Al Viro <viro@zeniv.linux.org.uk>
> 
>> + /* It's a really convoluted way for userland to ask for mmaped
>> +	 * sendmsg(), but that's what we've got...  */
> 
>    Hmm, not sure why DaveM hasn't commented on this broken comment
>    formatting (perhaps he was going to fix it while applying?). The
>    preferred comment style in the networking code is:
> 
> /* bla
>  * bla
>  */

Indeed, Al can you please audit your whole series for this issue and
respin?

Please also explicitly give me the GIT url to pull from each time you
post the series.

Thanks.
