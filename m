From: Ben Greear <greearb@candelatech.com>
Subject: Re: via-rhine unable to send back-to-back packets?
Date: Tue, 30 Nov 2004 09:41:23 -0800
Message-ID: <41ACB0C3.5020408@candelatech.com>
References: <20041129222700.GA22918@xi.wantstofly.org> <20041129172540.6b959858.davem@davemloft.net> <20041130064823.GA27872@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041130064823.GA27872@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:

> Yeah, preamble (8 bytes), CRC (4 bytes), inter-packet gap (12 bytes).
> 
> Perhaps the via-rhine simply can't send out packets back-to-back and
> needs 14 byte times of inter-packet gap.  I couldn't find any stray +2
> in the driver anywhere but I'm just checking.

Couldn't you just sniff the resulting traffic to see if it is too big?

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
