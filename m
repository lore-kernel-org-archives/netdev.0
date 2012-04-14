From: "Huang, Xiong" <xiong@qca.qualcomm.com>
Subject: RE: [PATCH 04/37] atl1c: remove VPD register
Date: Sat, 14 Apr 2012 09:12:18 +0000
Message-ID: <157393863283F442885425D2C454285623D486D9@nasanexd02a.na.qualcomm.com>
References: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
	<1334276102-15866-5-git-send-email-xiong@qca.qualcomm.com>
 <20120413.204551.959091962456153270.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qca-linux-team <qca-linux-team@qualcomm.com>,
	nic-devel <nic-devel@qualcomm.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120413.204551.959091962456153270.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Saturday, April 14, 2012 8:46
> To: Huang, Xiong
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; qca-linux-team; nic-
> devel
> Subject: Re: [PATCH 04/37] atl1c: remove VPD register
> 
> From: xiong <xiong@qca.qualcomm.com>
> Date: Fri, 13 Apr 2012 08:14:29 +0800
> 
> > VPD register is only used for L1(devid=PCI_DEVICE_ID_ATTANSIC_L1) to
> > access external NV-memory.
> > l1c & later chip doesn't use it any more.
> >
> > Signed-off-by: xiong <xiong@qca.qualcomm.com>
> > Tested-by: Liu David <dwliu@qca.qualcomm.com>
> 
> You just broke ethtool register dumps with this change.
> 
> Now, all the initial registers are reported offset by one entry, yet the last two are
> still reported in their original spots.
> 
> This layout is exposed to userspace, and interpreted by tools, and you cannot
> change it.
> 
> If this register always reports some value, you should just keep it there in the
> dumps.
>
The VPD register doesn't report anything :(, just a dummy register now.
we don't have any special tools in userspace to explain the dumped registers.
Actually the purpose of dumping these registers via ethtool is just for debug.


> I think you guys are way too aggressively removing things from the driver.
> 
> You are also posting way too many patches at one time.
> 
> If you post so many patches at once, if one of the early patches have a problem
> (as already is the case here) it means all the rest of your patches will not apply
> without offsets or rejects and therefore will all need to be redone and
> resubmitted.
> 
> Posting too many patches at once also creates a large burdon for those who will
> choose to help review your changes.
> 
> Send a small, reasonable, number of patches at one time.  Say, for example, 10
> or 15 maximum.

Completely agree.


Thanks
Xiong
