From: Ben Greear <greearb@candelatech.com>
Subject: Re: inter-packet gap in pktgen
Date: Fri, 10 Dec 2004 15:01:45 -0800
Message-ID: <41BA2AD9.7040404@candelatech.com>
References: <20041207222522.GA30266@xi.wantstofly.org> <41B632F3.1090104@candelatech.com> <20041208073858.GA4027@xi.wantstofly.org> <16822.54722.755218.745451@robur.slu.se> <41B756BE.3050504@candelatech.com> <20041210222913.GC5984@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, hadi@cyberus.ca,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041210222913.GC5984@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:
> On Wed, Dec 08, 2004 at 11:32:14AM -0800, Ben Greear wrote:
> 
> 
>>Actually, yes.  My pktgen no longer busy-spins.  [...]
> 
> 
> If you post a patch we can all perhaps have a look at it?

My consolidated patch, which includes pktgen (with rx-pktgen logic),
macvlans, my send-to-self patch, some e100 and e1000 diagnostics work, etc,
can be found here:

http://www.candelatech.com/oss/candela_2.6.9.patch

The pktgen diff is about the same size as the pktgen.c file, so I also
uploaded the pktgen files here:

http://www.candelatech.com/oss/pktgen.h
http://www.candelatech.com/oss/pktgen.c

Enjoy,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
