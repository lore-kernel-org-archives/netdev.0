From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: How to count tx and rx bytes?
Date: Tue, 16 Dec 2003 14:38:16 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031216143816.A1546@sygehus.dk>
References: <3FDE13AE.3050402@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <3FDE13AE.3050402@candelatech.com>; from greearb@candelatech.com on Mon, Dec 15, 2003 at 12:03:58PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Dec 15, 2003 at 12:03:58PM -0800, Ben Greear wrote:
> 
> Is there an agreed upon standard for exactly what ethernet drivers
> should be counting for rx-bytes and tx-bytes?  For example, should the
> counters include the 4-byte FCS?  Should they include the ethernet header?

Should they include the frame padding in tx-bytes? Some do, some don't.
IMHO they should, because you do actually transmit those bytes on the wire.

-- 
Regards,
Rask Ingemann Lambertsen
