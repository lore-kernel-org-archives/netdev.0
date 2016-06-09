From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] iucv: properly clone LSM attributes to newly created
 child sockets
Date: Thu, 09 Jun 2016 12:01:08 -0700 (PDT)
Message-ID: <20160609.120108.214498005489658934.davem@davemloft.net>
References: <146547719343.9258.4899338680484754606.stgit@localhost>
	<CAGH-Kgs-jg381WW818NKhdCkd06yXSRrgN0+A4migVM6FwUSVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-s390@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49397 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbcFITBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 15:01:09 -0400
In-Reply-To: <CAGH-Kgs-jg381WW818NKhdCkd06yXSRrgN0+A4migVM6FwUSVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Thu, 9 Jun 2016 09:01:52 -0400

> On Thu, Jun 9, 2016 at 8:59 AM, Paul Moore <pmoore@redhat.com> wrote:
>> From: Paul Moore <paul@paul-moore.com>
>>
>> Much like we had to do for AF_BLUETOOTH and AF_ALG, make sure we
>> properly clone the parent socket's LSM attributes to newly created
>> child sockets.
>>
>> Signed-off-by: Paul Moore <paul@paul-moore.com>
>> ---
>>  net/iucv/af_iucv.c |    5 ++++-
>>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> Another small, and obvious, fix so I'm going to merge it into
> selinux#next now, but if anyone has an objection please let me know.

This is fine.
