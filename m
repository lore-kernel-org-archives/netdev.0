From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 1/2] net: introduce generic net_random_N helper
Date: Tue, 03 Sep 2013 13:40:33 +0200
Message-ID: <5225CAB1.7080402@redhat.com>
References: <1378204010-27050-1-git-send-email-dborkman@redhat.com>  <1378204010-27050-2-git-send-email-dborkman@redhat.com> <1378206045.2048.9.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	"Theodore Ts'o" <tytso@mit.edu>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62925 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932595Ab3ICLkk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 07:40:40 -0400
In-Reply-To: <1378206045.2048.9.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2013 01:00 PM, Joe Perches wrote:
> On Tue, 2013-09-03 at 12:26 +0200, Daniel Borkmann wrote:
>> We have implemented the same function over and over, so introduce a
>> generic helper net_random_N() that unifies these implementations.
>> It internally used net_random() which eventually resolves to
>> prandom_u32(). Explicit include of reciprocal_div.h is not necessary.
>
> Perhaps adding a generic helper to random.h like
> 	u32 prandom_u32_between(u32 low, u32 high);
> or
> 	u32 prandom_u32_range(u32 bound1, u32 bound2)
> would be better.

Sure, this could be done as a follow-up. Once, we've migrated users to
the new API, follow-ups could go ahead to do the rest, and migration
will be easy. Note that the lower bound is 0 here.
