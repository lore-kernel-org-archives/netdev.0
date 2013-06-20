From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH v2 4/4] neigh: don't leak default parms to uninitial netns
Date: Thu, 20 Jun 2013 09:18:48 +0800
Message-ID: <51C25878.2070302@cn.fujitsu.com>
References: <1371175607-1405-1-git-send-email-gaofeng@cn.fujitsu.com> <1371175607-1405-4-git-send-email-gaofeng@cn.fujitsu.com> <20130619.180505.1958820391321832484.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62371 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S934734Ab3FTBRM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 21:17:12 -0400
In-Reply-To: <20130619.180505.1958820391321832484.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/20/2013 09:05 AM, David Miller wrote:
> From: Gao feng <gaofeng@cn.fujitsu.com>
> Date: Fri, 14 Jun 2013 10:06:47 +0800
> 
>> Only allow initial net namespace to get default parms
>> through netlink.
>>
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> 
> Disallowing changes to the default neigh parms is fine, but there is no
> reason to forbid seeing what default neigh parms will be used in a given
> network namespace just because it isn't &init_net.
> 

Yes, we can make sure un-init net namespace can't do harm to default neigh parms,
it's enough.

> I don't see why you want to restrict this at all.
> 
> I'm not applying these patches, sorry.

You can just drop this one, are there some problems with the other 3 patches?
