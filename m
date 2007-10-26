From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [2.6 patch] always export sysctl_{r,w}mem_max
Date: Fri, 26 Oct 2007 16:31:47 -0700
Message-ID: <472278E3.4000909@hp.com>
References: <20071026230807.GE30533@stusta.de> <m1zly5wjie.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:36872 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752308AbXJZXbu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 19:31:50 -0400
In-Reply-To: <m1zly5wjie.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Adrian Bunk <bunk@kernel.org> writes:
> 
> 
>>This patch fixes the following build error with CONFIG_SYSCTL=n:
>>
>><--  snip  -->
>>
>>...
>>ERROR: "sysctl_rmem_max" [fs/dlm/dlm.ko] undefined!
>>ERROR: "sysctl_wmem_max" [drivers/net/rrunner.ko] undefined!
>>ERROR: "sysctl_rmem_max" [drivers/net/rrunner.ko] undefined!
>>make[2]: *** [__modpost] Error 1
> 
> 
> I was going to ask if allowing drivers to increase rmem_max
> is something that we want to do.  Apparently the road runner
> driver has been doing this since the 2.6.12-rc1 when the
> git repository starts so this probably isn't a latent bug.

Although it does rather sound like a driver writer yanking the rope from the 
hand's of the sysadmin and hanging him with it rather than letting the sysadmin 
do it himself.  I've seen other drivers' README's suggesting larger mem's but 
not their sources doing it.

rick jones

