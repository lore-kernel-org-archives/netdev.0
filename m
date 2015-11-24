From: David Miller <davem@davemloft.net>
Subject: Re: use-after-free in sctp_do_sm
Date: Tue, 24 Nov 2015 16:12:21 -0500 (EST)
Message-ID: <20151124.161221.2298803524396370874.davem@davemloft.net>
References: <CACT4Y+aAYy4-Ow+gt+1C46CK1+MbspBMM7qz9pVYsXvGXRJ1SQ@mail.gmail.com>
	<CACT4Y+YjAhRSYDFUZYydtWfRzi1yDEKtPrPsJqYN93Km91J=Cw@mail.gmail.com>
	<20151124204553.GB3364@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, vyasevich@gmail.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	syzkaller@googlegroups.com, kcc@google.com, glider@google.com,
	sasha.levin@oracle.com, edumazet@google.com, maze@google.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45978 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753535AbbKXVMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 16:12:23 -0500
In-Reply-To: <20151124204553.GB3364@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 24 Nov 2015 15:45:54 -0500

>> The right commit is:
>> 
>> commit 7d267278a9ece963d77eefec61630223fce08c6c
>> Author: Rainer Weikusat
>> Date:   Fri Nov 20 22:07:23 2015 +0000
>>     unix: avoid use-after-free in ep_remove_wait_queue
> This commit doesn't seem to exist

It's in the 'net' tree.  Which hasn't been pulled into 'net-next' for
a few days.
