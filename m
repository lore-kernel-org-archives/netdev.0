From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC:  Enabling ethernet drivers to return FCS in the skb?
Date: Wed, 19 Nov 2003 07:33:53 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FBB8D61.6010106@candelatech.com>
References: <3FB94311.10004@candelatech.com> <20031119123556.A7622@sygehus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rask Ingemann Lambertsen <rask@sygehus.dk>
In-Reply-To: <20031119123556.A7622@sygehus.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rask Ingemann Lambertsen wrote:
> On Mon, Nov 17, 2003 at 01:52:17PM -0800, Ben Greear wrote:
> 
>>Is there any interest in adding an Ethtool command to tell the driver to
>>push the extra 4 bytes of CSUM into the skb?
>>
>>When enabling this feature, I'd also like to allow drivers to receive
>>frames with bad FCS as well.
> 
> [cut]
> 
>>At least some hardware appears
>>to support receiving bad FCS frames (e1000, evidently), but I am not sure
>>how wide-spread this feature is...
> 
> 
> The Intel i82586 and i82596 and can be told to receive frames with a bad FCS.
> They can also be told to send a precomputed FCS rather than computing it on
> the fly. The i82596 and tulip can also transfer the FCS to memory when
> receiving frames. I guess all of this is also supported on the i82557/8/9.

If you have a patch or example code that shows how to do this, I'd love to
see it.  I have code that should RX bad CSUM from the Intel folks, but I can't
get it to generate bad CRC (it does framing errors instead with my attempt),
so I can't test the RX code properly!

I have the path from user-space to the NIC written, so just need to tweak the
drivers a bit...

Do you know if tulip can be told to accept bad FCS and/or if it can generate
a frame with bad FCS somehow?

Thanks!
Ben

> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
