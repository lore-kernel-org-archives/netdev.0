From: Ben Greear <greearb@candelatech.com>
Subject: Re: latest -stable breaks Squid
Date: Wed, 03 May 2006 18:22:21 -0700
Message-ID: <4459574D.6000303@candelatech.com>
References: <E1FbSM8-0002lx-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org,
	stable@vger.kernel.org, fedora-list@list.zikzak.de,
	fedoralist@kotoulas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:45244 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1750723AbWEDBWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 21:22:46 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1FbSM8-0002lx-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Dave Jones <davej@redhat.com> wrote:
> 
>>So I pushed out an update for Fedora Core 5 users yesterday
>>that moved the kernel from 2.6.16.9 to 2.6.16.13.
>>I've since heard "My network performance is awful", and worse
>>yet, some apps seem broken as in the report below.
>>
>>Anyone have any ideas ?
> 
> 
> Try reverting the e1000 truesize patch.  Although the fix is 100%
> correct, it might have a negative impact on user-space apps with
> particuarly small rcvbuf settings.  Prior to the fix, due to the
> incorrect accounting we are essentially enlarging rcvbuf by as much
> as 10 times.

At least one of the reports shows problems with non e1000 NICs, so it's
probably not just the e1000 change.

https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=190620

Ben

> 
> Cheers,


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

