From: Ben Greear <greearb@candelatech.com>
Subject: Re: Deleting incoming network packets / sk_buff
Date: Sun, 15 Aug 2004 11:18:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411FA902.8070402@candelatech.com>
References: <411E642C.9010708@web.de> <411E8EE4.70900@candelatech.com> <411FA5D0.6000004@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Renzmann <mrenzmann@web.de>
In-Reply-To: <411FA5D0.6000004@web.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Renzmann wrote:

> Bottom line: the easiest way to solve this problem would be to have some 
> way for blocking packets on eth1 from being processed (after they have 
> been passed to the packet socket - else my userspace program won't be 
> able to "bridge" incoming packets to tap0).

Can't you have no IP on eth1 and have your IP on tap0 instead?  That would
at least keep any pkts received on eth1 from being processed by the
IP stack.

Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
