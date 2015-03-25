From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipvlan: fix addr hash list corruption
Date: Wed, 25 Mar 2015 11:46:22 -0400 (EDT)
Message-ID: <20150325.114622.1915164845375005128.davem@davemloft.net>
References: <20150324180628.278017fb@griffin>
	<CAF2d9jh+VozezamrEK_6vfTvY8LZSzw9n-bJjSX3G11RXmfz3w@mail.gmail.com>
	<20150325095851.1d8d1622@griffin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, netdev@vger.kernel.org, dcbw@redhat.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47230 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932203AbbCYPqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 11:46:24 -0400
In-Reply-To: <20150325095851.1d8d1622@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Wed, 25 Mar 2015 09:58:51 +0100

> On Tue, 24 Mar 2015 16:16:38 -0700, Mahesh Bandewar wrote:
>> Well, we already have hlist_unhashed().The following patch should fix
>> the duplicate addition as well as deletion. Please give it a try.
> 
> Good idea, it's surely better than adding a new boolean.
> 
> However, I'm wondering that when there's apparently no problem with the
> addresses being on the hash list when interface is down, what's the
> point in clearing the hash list in the ndo_stop handler and
> repopulating it in ndo_open?
> 
> The following patch fixes the problem, too, and as a bonus removes code:

I'll let Mahesh reply to this.
