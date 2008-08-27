From: Jeff Garzik <jeff@garzik.org>
Subject: Re: mv643xx_eth fixes pull request for 2.6.27
Date: Wed, 27 Aug 2008 05:10:45 -0400
Message-ID: <48B51A15.5080801@garzik.org>
References: <20080824020324.GA8762@xi.wantstofly.org> <20080825203139.GA18649@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dale Farnsworth <dale@farnsworth.org>,
	Nicolas Pitre <nico@cam.org>, Andrew Morton <akpm@osdl.org>,
	Gerhard Bertelsmann <info@gerhard-bertelsmann.de>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52661 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753736AbYH0JKw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 05:10:52 -0400
In-Reply-To: <20080825203139.GA18649@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek wrote:
> On Sun, Aug 24, 2008 at 04:03:24AM +0200, Lennert Buytenhek wrote:
> 
>> The following five mv643xx_eth fixes for 2.6.27 since commit
>> 6a55617ed5d1aa62b850de2cf66f5ede2eef4825:
>>   Linus Torvalds (1):
>>         Linux v2.6.27-rc4
>>
>> are available in the git repository at:
>>
>>   git://git.marvell.com/mv643xx_eth.git for-2.6.27
>>   http://git.marvell.com/?p=mv643xx_eth.git;a=summary
>>
>> Lennert Buytenhek (5):
>>       mv643xx_eth: fix NAPI 'rotting packet' issue
>>       mv643xx_eth: fix double add_timer() on the receive oom timer
>>       mv643xx_eth: fix inconsistent lock semantics
>>       mv643xx_eth: fix NULL pointer dereference in rxq_process()
>>       mv643xx_eth: enforce multiple-of-8-bytes receive buffer size restriction
>>
>>  drivers/net/mv643xx_eth.c |   33 +++++++++++++++++++--------------
>>  1 files changed, 19 insertions(+), 14 deletions(-)
>>
>> The second patch should fix http://bugzilla.kernel.org/show_bug.cgi?id=11377
>> -- Gerhard, can you please test if it makes your problem go away?  (It
>> won't make the out of memory messages go away, but it should fix the
>> kernel panic.)
> 
> The submitter confirmed that patch 2 fixes the original issue (and
> once that is fixed, patch 4 will fix the subsequently emerging issue).
> I've also done some more testing on the series, and it's probably good
> for 2.6.27.  I've tacked on a patch to bump the version number -- can
> you please pull?
> 
> The following changes since commit 6a55617ed5d1aa62b850de2cf66f5ede2eef4825:
>   Linus Torvalds (1):
>         Linux v2.6.27-rc4
> 
> are available in the git repository at:
> 
>   git://git.marvell.com/mv643xx_eth.git for-2.6.27
>   http://git.marvell.com/?p=mv643xx_eth.git;a=shortlog;h=for-2.6.27
> 
> Lennert Buytenhek (6):
>       mv643xx_eth: fix NAPI 'rotting packet' issue
>       mv643xx_eth: fix double add_timer() on the receive oom timer
>       mv643xx_eth: fix inconsistent lock semantics
>       mv643xx_eth: fix NULL pointer dereference in rxq_process()
>       mv643xx_eth: enforce multiple-of-8-bytes receive buffer size restriction
>       mv643xx_eth: bump version to 1.3
> 
>  drivers/net/mv643xx_eth.c |   35 ++++++++++++++++++++---------------
>  1 files changed, 20 insertions(+), 15 deletions(-)

pulled


