From: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>
Subject: Re: [PATCH] [2.4] forcedeth network driver
Date: Sat, 24 Jan 2004 23:33:27 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4012F2B7.3080800@gmx.net>
References: <4012BF44.9@colorfullife.com> <4012D3C6.1050805@pobox.com> <20040124220545.GA3246@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Manfred Spraul <manfred@colorfullife.com>,
        linux-kernel@vger.kernel.org, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Vojtech Pavlik <vojtech@suse.cz>
In-Reply-To: <20040124220545.GA3246@ucw.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Vojtech Pavlik wrote:
> On Sat, Jan 24, 2004 at 03:21:26PM -0500, Jeff Garzik wrote:
> 
>>>>>+static int alloc_rx(struct net_device *dev)
>>>>>+{
>>>
>>>[snip]
>>>
>>>>>+    return 0;
>>>>>+}
>>>>
>>>>skb_reserve() seems to be missing
>>>>
>>>
>>>Do you have specs that show that all nForce versions support unaligned 
>>>buffers? skb_reserve is a performance feature, I don't want to add it 
>>>yet. Testing that it works is on our TODO list.
>>
>>hmmmm, is nForce ever found on non-x86 boxes?  I would think that 
>>skb_reserve might be -required- for some platforms.
> 
> 
> AMD64 and PPC64 as far as I know. But you may consider the first one
> still a x86 box.

Hmmm. I thought only GeForce graphics were available on PPC64 and nForce
mainboard chipsets (including the onboard nic) were not.


Carl-Daniel
-- 
http://www.hailfinger.org/
