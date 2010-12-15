From: Vladislav Bolkhovitin <vst@vlnb.net>
Subject: Re: After memory pressure: can't read from tape anymore
Date: Wed, 15 Dec 2010 19:27:42 +0300
Message-ID: <4D08EC7E.5080201@vlnb.net>
References: <1290971729.2814.13.camel@larosa>	<alpine.LNX.2.00.1011291857420.7923@kai.makisara.local>	<20101203212453W.fujita.tomonori@lab.ntt.co.jp>	<4CF905D1.6050903@kolumbus.fi>	<1291388776.2881.4.camel@mulgrave.site>	<1291395815.2814.376.camel@larosa>	<1291399814.2881.66.camel@mulgrave.site>	<4D07D519.70800@vlnb.net> <20101214142320.27d911d5@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: James Bottomley <James.Bottomley@suse.de>,
	Lukas Kolbe <lkolbe@techfak.uni-bielefeld.de>,
	=?ISO-8859-1?Q?Kai_M=E4kisara?= <kai.makisara@kolumbus.fi>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	linux-scsi@vger.kernel.org, Kashyap Desai <Kashyap.Desai@lsi.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20101214142320.27d911d5@nehalam>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger, on 12/15/2010 01:23 AM wrote:
> On Tue, 14 Dec 2010 23:35:37 +0300
> Vladislav Bolkhovitin <vst@vlnb.net> wrote:
> 
>> What is interesting to me in this regard is how networking with 9K jumbo
>> frames manages to work acceptably reliable? Jumbo frames used
>> sufficiently often, including under high memory pressure.
>>
>> I'm not a deep networking guru, but network drivers need to allocate
>> physically continual memory for skbs, which means 16K per 9K packet,
>> which means order 2 allocations per skb.
> 
> Good network drivers support fragmentation and allocate a small portion
> for the header and allocate pages for the rest. This requires no higher
> order allocation. The networking stack takes fragmented data coming
> in and does the necessary copy/merging to access contiguous headers.
> 
> There are still some crap network drivers that require large contiguous
> allocation. These should not be used with jumbo frames in real
> environments.

I see. Thanks for clarifying it.

Vlad



