From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: [PATCH]  e100: Enable receiving bogus packets, and transmitting bad/custom CRC
Date: Sat, 13 Dec 2003 20:00:45 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031213200044.B1791@sygehus.dk>
References: <3FC2931B.3070903@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <3FC2931B.3070903@candelatech.com>; from greearb@candelatech.com on Mon, Nov 24, 2003 at 03:24:11PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 24, 2003 at 03:24:11PM -0800, Ben Greear wrote:
> Thanks to those who pointed me in the right direction, here is a patch
> to the e100 (2.4.23-pre9) that allows it to capture all frames, bogons included.
> It also coppies the FCS to the skb so ethereal et al can read it.
> 
> It utilizes ethtool commands to get/set the rx-all feature, and uses
> a new flag in the skbuff (and socket struct) structure to determine when to disable generating
> the FCS on transmit.  I have the entire patch that adds the management
> bits and flags, but as usual, it's mixed in with various other things...

Reading the tulip manual (see below) triggered a question: When transmitting
a custom CRC, who is responsible for padding the frame to the minimum length?
If frame padding is left to the driver, what should be used for padding?

I (or rather, Google) found the tulip documentation at
<URL:http://www.intel.com/design/network/manuals/278074.htm>. The tulip
chips are capable of all these tricks too.

-- 
Regards,
Rask Ingemann Lambertsen
