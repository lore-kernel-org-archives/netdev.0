From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: avoid br_ifinfo_notify when nothing
 changed
Date: Sun, 24 Mar 2013 17:15:37 -0400 (EDT)
Message-ID: <20130324.171537.1255124338630598287.davem@davemloft.net>
References: <1364015653-7322-1-git-send-email-honkiko@gmail.com>
	<1364131607-11698-1-git-send-email-honkiko@gmail.com>
	<514F0F07.9050702@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: honkiko@gmail.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, stephen@networkplumber.org,
	herbert@gondor.hengli.com.au, zhiguo.hong@emc.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43824 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754161Ab3CXVPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 17:15:38 -0400
In-Reply-To: <514F0F07.9050702@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 24 Mar 2013 17:34:47 +0300

> Hello.
> 
> On 03/24/2013 04:26 PM, Hong Zhiguo wrote:
> 
>> When neither IFF_BRIDGE nor IFF_BRIDGE_PORT is set,
>> and afspec == NULL but  protinfo != NULL, we run into
>> "if (err == 0) br_ifinfo_notify(RTM_NEWLINK, p);" with
>> random value in ret.
>>
>> Thanks to Sergei for pointing out the error in commit comments.
>>
>> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
> 
>     For the future, if you post the revised version of the patch, you
> should indicate in the subject it like this: [PATCH v2].

I'm disappointed that you have enough energy to point out such a lower
priority omission, but you lack the time for something more important,
which is giving this patch your explicit ACK if it fixes all of the
issues you pointed out to him.
