From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: RFC:  Enabling ethernet drivers to return FCS in the skb?
Date: Wed, 19 Nov 2003 12:35:57 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031119123556.A7622@sygehus.dk>
References: <3FB94311.10004@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Content-Disposition: inline
In-Reply-To: <3FB94311.10004@candelatech.com>; from greearb@candelatech.com on Mon, Nov 17, 2003 at 01:52:17PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 17, 2003 at 01:52:17PM -0800, Ben Greear wrote:
> Is there any interest in adding an Ethtool command to tell the driver to
> push the extra 4 bytes of CSUM into the skb?
> 
> When enabling this feature, I'd also like to allow drivers to receive
> frames with bad FCS as well.
[cut]
> At least some hardware appears
> to support receiving bad FCS frames (e1000, evidently), but I am not sure
> how wide-spread this feature is...

The Intel i82586 and i82596 and can be told to receive frames with a bad FCS.
They can also be told to send a precomputed FCS rather than computing it on
the fly. The i82596 and tulip can also transfer the FCS to memory when
receiving frames. I guess all of this is also supported on the i82557/8/9.

-- 
Regards,
Rask Ingemann Lambertsen
