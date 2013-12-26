From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: Re: [PATCH net-next 1/2] mlx4_en: Add PTP hardware clock
Date: Thu, 26 Dec 2013 10:33:26 +0200
Message-ID: <52BBE9D6.3040006@mellanox.com>
References: <1387312359-9476-1-git-send-email-shawn.bohrer@gmail.com> <1387312359-9476-2-git-send-email-shawn.bohrer@gmail.com> <52B6E568.4030400@mellanox.com> <20131223184845.GA4922@netboy> <52B992EE.5030401@mellanox.com> <20131225115322.GB5378@netboy> <52BBE84C.1030702@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Shawn Bohrer <shawn.bohrer@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tomk@rgmadvisors.com" <tomk@rgmadvisors.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:59507 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751381Ab3LZIeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 03:34:13 -0500
In-Reply-To: <52BBE84C.1030702@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/26/2013 10:26 AM, Hadar Hen Zion wrote:
> On 12/25/2013 1:53 PM, Richard Cochran wrote:
>> On Tue, Dec 24, 2013 at 03:58:06PM +0200, Hadar Hen Zion wrote:
>>>
>>> The spin locks case such a bottleneck since I'm using multiple
>>> streams in my performance test. RSS mechanism scattered the streams
>>> between multiple RX rings while each RX ring is bound to a different
>>> cup.
>>> The describe scenario cause lock contention between the different RX
>>> rings.
>>>
>>> Performance drops from 37.8 Gbits/sec to 32.1 Gbits/sec when spin
>>> locks are added and goes back to 37.8 Gbits/sec when using
>>> read/write locks.
>>
>> And you are time stamping every received packet?
>>
>> Thanks,
>> Richard
>>
>
> Yes, current implementation time stamping every received packet.
> I do think time stamping only packets from the relevant socket will make
> more sense but SIOCSHWTSTAMP ioctl provides only the device without any
> socket attributes.
>
> Thanks,
> Hadar
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Is there a way to time stamping packets per socket?

Thanks,
Hadar
