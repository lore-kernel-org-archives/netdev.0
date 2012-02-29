From: "Huang, Xiong" <xiong@qca.qualcomm.com>
Subject: RE: [PATCH] net: add QCA alx Ethernet driver
Date: Wed, 29 Feb 2012 07:30:20 +0000
Message-ID: <157393863283F442885425D2C454285619415703@nasanexd02a.na.qualcomm.com>
References: <157393863283F442885425D2C4542856194154FC@nasanexd02a.na.qualcomm.com>
	<20120228.212857.797446903975232476.davem@davemloft.net>
	<157393863283F442885425D2C454285619415561@nasanexd02a.na.qualcomm.com>
 <20120228.223258.2261979237568571219.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Rodriguez, Luis" <rodrigue@qca.qualcomm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qca-linux-team <qca-linux-team@qualcomm.com>,
	nic-devel <nic-devel@qualcomm.com>,
	"Giori, Kathy" <kgiori@qca.qualcomm.com>,
	"chris.snook@gmail.com" <chris.snook@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120228.223258.2261979237568571219.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My another concern is the license type. Current atl1c use GPL v2, and got some contribution outside of QCA though the first version 
was wrote by our Atheros guy. And that guy just copied the license from atl1e/atl1x that contains the words "Derived from Intel e1000".

If I update this driver and add new chip support on it, Our Company's legal might not permit me to do so, they prefer QCA ISC license.
Is it possible to change the license header to ISC while I applying patches to source code ?


Thanks
xiong

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, February 29, 2012 11:33
> To: Huang, Xiong
> Cc: Rodriguez, Luis; netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> qca-linux-team; nic-devel; Giori, Kathy; chris.snook@gmail.com; Olivari,
> Mathieu; Huntsman, Bryan
> Subject: Re: [PATCH] net: add QCA alx Ethernet driver
> 
> From: "Huang, Xiong" <xiong@qca.qualcomm.com>
> Date: Wed, 29 Feb 2012 03:11:14 +0000
> 
> > We understand your concern.  To support the new chipset, do you think
> > it's reasonable to upstream it as a new driver, not a replacement ?
> 
> It depends upon how similar the chips are.
> 
> To be honest tg3, as one example, supports quite a large array of different
> pieces of hardware that use the same logical core.
> 
> So that would be my litmus test about how different a chip needs to be to
> deserve an entirely new driver.
> 
> I strongly suggest you try to get atl1c working properly.
