From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: A new driver for Broadcom bcm5706
Date: Fri, 20 May 2005 20:01:23 -0400
Message-ID: <428E7A53.1030907@pobox.com>
References: <20050520194220.GA18259@havoc.gtf.org>	<20050520.152836.48528379.davem@davemloft.net>	<428E72F9.3070404@pobox.com> <20050520.164504.31639000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@oss.sgi.com, ffan@broadcom.com,
        lusinsky@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S.Miller" <davem@davemloft.net>
In-Reply-To: <20050520.164504.31639000.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S.Miller wrote:
> From: Jeff Garzik <jgarzik@pobox.com>
> Date: Fri, 20 May 2005 19:30:01 -0400
> 
> 
>>Sure.  What I'm driving at is that a checksum of zero seems to imply 
>>CHECKSUM_NONE not CHECKSUM_UNNECESSARY.  tg3 only does the 0xffff check.
> 
> 
> Sure, both ways are fine.

huh?  They are pretty different...  one says "Checksum all good, dude" 
and the other says "I didn't checksum, do it in software for me."

right?

	Jeff
