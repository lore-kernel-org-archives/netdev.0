From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] support for large number of network devices.
Date: Tue, 13 Jan 2004 16:23:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40048BFD.4010303@candelatech.com>
References: <20040113154610.38f5934c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040113154610.38f5934c.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> When using pseudo network devices, and really big machines; there is
> sometimes a need to have a lot of network devices.  This replaces the
> existing 2.6.1 limit of 100 entries an was O(n^2)
> with a algorithm that will handle up to 32768 entries with O(n) behaviour.

Might be a good time to put in hash tables to find network devices by
name and by device-id.  There are a few parts of the networking stack
that do lookups, and walking the device list when it's 4k entries
long takes a while...

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
