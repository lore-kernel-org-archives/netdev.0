From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] bonding work-queues, try_rtnl() &
 notifications
Date: Sat, 21 Mar 2015 22:16:31 -0400 (EDT)
Message-ID: <20150321.221631.908834228517236497.davem@davemloft.net>
References: <1426916355-18289-1-git-send-email-maheshb@google.com>
	<20150321.181700.1162404019090592599.davem@davemloft.net>
	<CAF2d9jhMz4Y1ye_ofkgvXyxUJEpNnLrFjMJhHQXKbf6MSS-OVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
	nikolay@redhat.com, maze@google.com, netdev@vger.kernel.org,
	edumazet@google.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42479 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691AbbCVCQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 22:16:33 -0400
In-Reply-To: <CAF2d9jhMz4Y1ye_ofkgvXyxUJEpNnLrFjMJhHQXKbf6MSS-OVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Sat, 21 Mar 2015 19:01:29 -0700

> I think you missed my earlier reply to your message. In summary, the
> notification deferral is 1ms which should not cause any trashing;
> more over with that suggested approach the rtnl-owner will have to
> do your job and will be subjected to the latencies which may be
> undesirable.

Someone has to do the work, and if the rtnl-owner does it we do not
incur all of the overhead the resubmission entails.

> OTOH this patch series is not adding any new deferral work, but just
> making it bug-free.

It's continuing a bad approach to the problem.
