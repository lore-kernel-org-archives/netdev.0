From: David Miller <davem@davemloft.net>
Subject: Re: [Drbd-dev] [PATCH 2/2 v2] netlink: kill eff_cap from struct
 netlink_skb_parms
Date: Thu, 03 Mar 2011 17:38:31 -0800 (PST)
Message-ID: <20110303.173831.226757550.davem@davemloft.net>
References: <20110303201522.GT4988@sequoia.sous-sol.org>
	<20110303223746.GI25069@barkeeper1-xen.linbit>
	<20110304012956.GA13573@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chrisw@sous-sol.org, linux-fbdev@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	dm-devel@redhat.com, kaber@trash.net, drbd-dev@lists.linbit.com
To: zbr@ioremap.net
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20110304012956.GA13573@ioremap.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Fri, 4 Mar 2011 04:29:56 +0300

> Hi.
> 
> On Thu, Mar 03, 2011 at 11:37:46PM +0100, Lars Ellenberg (lars.ellenberg@linbit.com) wrote:
>> If so, then this change introduces the possibility for normal users to
>> send privileged commands to connector based subsystems, even if they
>> may not be able to bind() to suitable sockets to receive any replies.
>> 
>> Am I missing something?
> 
> Yup, connector is very async at that place, but I wonder why the hell I
> ever made that decision. I believe we can replace it with pure sync call
> of the registered connector callback, since netlink is synchronous and
> no one has any problem with it.

Yes, please it would really help us with what we're trying to do here.
