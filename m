From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH] Infiniband: Randomize local port allocation.
Date: Wed, 14 Apr 2010 12:38:39 +0800
Message-ID: <4BC546CF.9020004@redhat.com>
References: <20100412100744.5302.92442.sendpatchset@localhost.localdomain>	<20100412100816.5302.74919.sendpatchset@localhost.localdomain>	<201004130121.o3D1Lhh7099571@www262.sakura.ne.jp>	<4BC41994.7030707@redhat.com>	<4BC42FE0.4040601@redhat.com> <201004132207.GAJ52684.OJFtMQVFHOSFLO@I-love.SAKURA.ne.jp> <21DAC78125424ED291B5D6477CFF9657@amr.corp.intel.com> <201004140201.o3E21Aqn075978@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: rolandd@cisco.com, sean.hefty@intel.com, opurdila@ixiacom.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	nhorman@tuxdriver.com, davem@davemloft.net, ebiederm@xmission.com,
	linux-kernel@vger.kernel.org
To: penguin-kernel@i-love.sakura.ne.jp
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201004140201.o3E21Aqn075978@www262.sakura.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

penguin-kernel@i-love.sakura.ne.jp wrote:
> Sean Hefty wrote:
>> Sean and Roland, is below patch correct?
>>> inet_is_reserved_local_port() is the new function proposed in this patchset.
>> It looks correct to me.  I didn't test the patch series, but if I comment out
>> the call to inet_is_reserved_local_port() in the provided below, the changes
>> worked fine for me.
>>
>> Acked-by: Sean Hefty <sean.hefty@intel.com>
>>
> Thank you for testing.
> 
> I think it is better to split this patch into
> 
> Part 1: Make cma_alloc_any_port() to use cma_alloc_port().
> 
> Part 2: Insert "!inet_is_reserved_local_port(rover) &&" line.
> 
> for future "git bisect".
> 

Right, thanks a lot for your work!

So, I will rebase my patch 3/3 on top of this patch. I hope someone
could take this one asap.
