From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipvlan: fix addr hash list corruption
Date: Tue, 24 Mar 2015 21:18:56 -0400 (EDT)
Message-ID: <20150324.211856.819259825188915132.davem@davemloft.net>
References: <20150324.130037.1897087027068811494.davem@davemloft.net>
	<20150324180628.278017fb@griffin>
	<CAF2d9jh+VozezamrEK_6vfTvY8LZSzw9n-bJjSX3G11RXmfz3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, netdev@vger.kernel.org, dcbw@redhat.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248AbbCYBS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 21:18:58 -0400
In-Reply-To: <CAF2d9jh+VozezamrEK_6vfTvY8LZSzw9n-bJjSX3G11RXmfz3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Tue, 24 Mar 2015 16:16:38 -0700

> Well, we already have hlist_unhashed().The following patch should fix
> the duplicate addition as well as deletion. Please give it a try.

Yes, this looks a _lot_ better.
