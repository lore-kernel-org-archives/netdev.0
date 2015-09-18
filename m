From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] netlink: make sure -EBUSY won't escape from netlink_insert
Date: Fri, 18 Sep 2015 10:05:38 +0200
Message-ID: <55FBC5D2.20200@iogearbox.net>
References: <d466c48264ca677f0fc61ff76526780c32c37cb5.1438898409.git.daniel@iogearbox.net> <20150810.110015.1616067694505641781.davem@davemloft.net> <20150917054114.GN1983@Chimay.local> <CA+55aFxyqfxJphqDF_X4hG40b21XWP0fFdMhFJKn6riy5-kmtA@mail.gmail.com> <20150918020922.GA30070@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Paasch <christoph.paasch@gmail.com>,
	David Miller <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Network Development <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60847 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbbIRIFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 04:05:46 -0400
In-Reply-To: <20150918020922.GA30070@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/18/2015 04:09 AM, Herbert Xu wrote:
> On Thu, Sep 17, 2015 at 11:47:12AM -0700, Linus Torvalds wrote:
>> On Wed, Sep 16, 2015 at 10:41 PM, Christoph Paasch
>> <christoph.paasch@gmail.com> wrote:
>>>
>>> can this patch get queued up for 4.1 as well?
>>> It seems to fix a similar issue in 4.1.6.
>>
>> I think Herbert has an additional patch for this issue. But yes, I
>> think should be scheduled for stable. Herbert?
>
> Yes this should be safe for stable, even though the real cause of
> the problem is probably the one that Tejun spotted.

Yes, agreed.

Thanks,
Daniel
