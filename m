From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH,pktgen] account for preamble and inter-packet gap
Date: Sun, 28 Nov 2004 19:21:31 -0800
Message-ID: <41AA95BB.7060400@candelatech.com>
References: <20041128213251.GA9330@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041128213251.GA9330@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:
> Hi!
> 
> If you account for the Frame Check Sequence when computing bandwidth
> stats, it's only fair that you count the preamble and inter-packet gap
> as well.  Suggested patch attached.

a) When an ethernet NIC claims 100Mbps, does this count the preamble and IPG?

b) Or, can send and receive 100Mbps of data by only counting
    the ethernet header + payload + CRC?

If b is true, then I definately would not want to see the IPG and preamble
counted.  If a is true, then I still don't want it counted, but I would
agree that it is worth considering :)

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
