From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC: another approach for 64-bit network stats
Date: Mon, 07 Jul 2003 09:53:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F09A57D.8030003@candelatech.com>
References: <3F097E4D.1080707@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <3F097E4D.1080707@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> This patch implements a lockless aproach for 64-bit netstatistics with 
> only a very rare
> racecondition. On 64 bit system, nothing is changed. On 32 bit system 

I think that you should consider providing a new API as opposed to
breaking existing APIs.

And, perhaps this new API could deal with the very rare race to make
it never happen?  No matter how rare it is, you still have to write code
to work around it if it exists..might as well do it once in the kernel
instead of making each user of the interface deal with it.

Personally, I'd like to see the net-device stats (64-bit or otherwise) available
through the ethtool interface in a well defined binary package (perhaps a
struct net_device_stats, or similar.)

Ben



-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
