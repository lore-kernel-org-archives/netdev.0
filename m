From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [RFC PATCH] ipv6: Split from and expires field in dst_entry out
 of union [net-next]
Date: Wed, 20 Feb 2013 17:31:26 +0800
Message-ID: <512497EE.8000100@cn.fujitsu.com>
References: <1361231718.19353.117.camel@edumazet-glaptop>   <1361305694-8303-1-git-send-email-nhorman@tuxdriver.com>   <1361308665.19353.161.camel@edumazet-glaptop>   <20130219214934.GD31871@hmsreliant.think-freely.org>  <1361310958.19353.164.camel@edumazet-glaptop>  <51246E43.5010202@cn.fujitsu.com> <1361343610.19353.177.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, Jiri Bohac <jbohac@suse.cz>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:9757 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S933163Ab3BTJao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2013 04:30:44 -0500
In-Reply-To: <1361343610.19353.177.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/02/20 15:00, Eric Dumazet wrote:
> On Wed, 2013-02-20 at 14:33 +0800, Gao feng wrote:
> 
>> How can we?
>> one usage of rt6_update_expires and rt6_set_expires
>> is changing rt6->dst.from to rt6->dst.expires, we should release the
>> already holded reference of rt6->dst.from.
>>
> 
> Just don't union the two fields, as Neil did.
> 
> Setting the dst.expires value should not change dst.from at all.
> 

Get it,it looks good to me.we can make sure dst->from doesn't
being operated at same time.

Thanks!
