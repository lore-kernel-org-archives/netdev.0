From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net 2/3] r8152: modify the tx flow
Date: Wed, 30 Oct 2013 11:03:55 +0800
Message-ID: <7F69554959F74FA58AE07F06B9FCF029@realtek.com.tw>
References: <1383033377-1178-1-git-send-email-hayeswang@realtek.com><1383033377-1178-3-git-send-email-hayeswang@realtek.com> <20131029.174936.13317032766742363.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, 'nic_swsd' <nic_swsd@realtek.com>,
	<linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131029.174936.13317032766742363.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 David Miller [mailto:davem@davemloft.net] 
> Sent: Wednesday, October 30, 2013 5:50 AM
> To: Hayeswang
> Cc: netdev@vger.kernel.org; nic_swsd; 
> linux-kernel@vger.kernel.org; linux-usb@vger.kernel.org
> Subject: Re: [PATCH net 2/3] r8152: modify the tx flow
> 
> From: Hayes Wang <hayeswang@realtek.com>
> Date: Tue, 29 Oct 2013 15:56:16 +0800
> 
> > Support stopping and waking tx queue. The maximum tx queue length
> > is 60.
> 
> What is so special about the number 60?  It seems arbitrary, and if
> it isn't arbitrary you haven't described why this value was choosen.

The value is arbitrary. I think it is better to stop tx when
queuing many packets, otherwise all the available memory may
be used for tx skb. The queue length could be any value or
unlimited if the memory is enough. Should I remove it?

> I've asked you politely last time around to significantly improve
> the quality of your commit messages, and you haven't done this at
> all.

I thought you indicated the last patch only and the others are clear enough.
I would improve them.

> I'm not applying any of these patches until your commit messages
> properly describe your changes completely.
> 
