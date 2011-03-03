From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netlink: kill eff_cap from struct netlink_skb_parms
Date: Thu, 03 Mar 2011 10:56:55 -0800 (PST)
Message-ID: <20110303.105655.189705829.davem@davemloft.net>
References: <4D6F6180.5030903@trash.net>
	<20110303173230.GP4988@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, dm-devel@redhat.com,
	linux-security-module@vger.kernel.org, drbd-dev@lists.linbit.com
To: chrisw@sous-sol.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20110303173230.GP4988@sequoia.sous-sol.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Wright <chrisw@sous-sol.org>
Date: Thu, 3 Mar 2011 09:32:30 -0800

> * Patrick McHardy (kaber@trash.net) wrote:
> 
>> commit 8ff259625f0ab295fa085b0718eed13093813fbc
>> Author: Patrick McHardy <kaber@trash.net>
>> Date:   Thu Mar 3 10:17:31 2011 +0100
>> 
>>     netlink: kill eff_cap from struct netlink_skb_parms
>>     
>>     Netlink message processing in the kernel is synchronous these days,
>>     capabilities can be checked directly in security_netlink_recv() from
>>     the current process.
>>     
>>     Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> Thanks for doing that Patrick.  I looked at this earlier and thought
> there was still an async path, but I guess that's just to another
> userspace process.
> 
> BTW, I think you missed a couple connector based callers:
> 
> drivers/staging/pohmelfs/config.c:      if (!cap_raised(nsp->eff_cap, CAP_SYS_AD
> drivers/video/uvesafb.c:        if (!cap_raised(nsp->eff_cap, CAP_SYS_ADMIN))
> 
> Fix those and:
> 
> Acked-by: Chris Wright <chrisw@sous-sol.org>

Patrick, I'll apply your first patch, please respin this second patch with
the changes mentioned here.

Thanks!
