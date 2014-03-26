From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/2] net: tcp_ipv6 do some cleanup
Date: Wed, 26 Mar 2014 17:07:20 -0400 (EDT)
Message-ID: <20140326.170720.1620895694123455490.davem@davemloft.net>
References: <1395642322-9404-1-git-send-email-wangyufen@huawei.com>
	<20140326.154255.1270995413257461102.davem@davemloft.net>
	<1395866443.3726.43.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangyufen@huawei.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47197 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756459AbaCZVHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 17:07:22 -0400
In-Reply-To: <1395866443.3726.43.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 26 Mar 2014 13:40:43 -0700

> On Wed, 2014-03-26 at 15:42 -0400, David Miller wrote:
>> From: Wangyufen <wangyufen@huawei.com>
>> Date: Mon, 24 Mar 2014 14:25:21 +0800
>> 
>> > -static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
>> > +static int tcp_v6_parse_md5_keys(struct sock *sk, char __user *optval,
>> >  				  int optlen)
>> 
>> If you change the first line, you must adjust the indentation of the second
>> line so that "int optlen)" begins precisely at the first column after the
>> openning parenthesis on the first line.
> 
> checkpatch's --strict option emits a message about alignment
> issues like this.
> 
> David, do you want the --strict option to be auto-enabled for
> patches of files in drivers/net and net/?

I know this doesn't help, but I'm ambivalent.
