From: David Miller <davem@davemloft.net>
Subject: Re: cls_cgroup: Store classid in struct sock
Date: Sun, 23 May 2010 23:44:41 -0700 (PDT)
Message-ID: <20100523.234441.66200781.davem@davemloft.net>
References: <20100521110847.GA29878@gondor.apana.org.au>
	<20100521164054.GB29521@hmsreliant.think-freely.org>
	<20100522014957.GA8779@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, eric.dumazet@gmail.com, bmb@athenacr.com,
	tgraf@redhat.com, nhorman@redhat.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42476
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755808Ab0EXGob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 02:44:31 -0400
In-Reply-To: <20100522014957.GA8779@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 22 May 2010 11:49:57 +1000

> On Fri, May 21, 2010 at 12:40:54PM -0400, Neil Horman wrote:
>> 
>> There may also be an issue with the setting of the classid (possible use of the
>> wrong subsys id value when grabbing our cgroup_subsys_state), but I'm checking
>> on that now.
> 
> Actually, I think it's because my patch mistook CONFIG_CGROUP
> for CONFIG_CGROUPS.
> 
> Here is a fixed version (also includes a build fix on sk->classid).
> 
> cls_cgroup: Store classid in struct sock

BTW I made sure to apply this version.
