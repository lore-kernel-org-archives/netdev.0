From: Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
Subject: Re: [PATCH net-next v4 0/3] Linn Ethernet Packet Sniffer driver
Date: Wed, 25 Feb 2015 17:12:08 +0000
Message-ID: <54EE0268.2040201@linn.co.uk>
References: <cover.1424796018.git.stathis.voukelatos@linn.co.uk> <20150225151945.GB7703@localhost.localdomain> <20150225170127.GD7703@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150225170127.GD7703-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Richard,

On 25/02/15 17:01, Richard Cochran wrote:
> On Wed, Feb 25, 2015 at 04:19:45PM +0100, Richard Cochran wrote:
>> Let me suggest another approach that stays in line with the existing
>> frame work.  Based on the device's limitations and your own example,
>> it seems clear that the intended use case is synchronization for AVB
>> applications using gPTP.
>
> Also, forgot to say, expose your clock as a PTP Hardware Clock (PHC).
>

Regarding this last point, the actual counter that generates the 
timestamps is not part of the sniffer H/W module. Timestamps are 
provided to the sniffer externally in H/W by a different module.
Apart of that there is not eg. a sniffer register to read the current 
counter value. I wonder if it should be the driver for the module where 
the counter belongs (called Event Timer in the Pistachio Soc) that 
should register the PHC.

I need some more time to study your other suggestions regarding the PHY 
timestamping framework.

> Thanks,
> Richard
>

Regards,
Stathis
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
