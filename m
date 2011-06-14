From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH net-next 0/24] bnx2x: New FW and support for 578xx
Date: Tue, 14 Jun 2011 19:22:40 +0300
Message-ID: <201106141922.40906.vladz@broadcom.com>
References: <201106141213.34576.vladz@broadcom.com>
 <201106141432.32257.vladz@broadcom.com>
 <20110614.115402.426774711287563448.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>,
	"Bhanu (Venkata Bhanu Prakash) Gollapudi" <bprakash@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>,
	"dwmw2@infradead.org" <dwmw2@infradead.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3417 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750864Ab1FNQW7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 12:22:59 -0400
In-Reply-To: <20110614.115402.426774711287563448.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 14 June 2011 18:54:02 David Miller wrote:
> From: "Vlad Zolotarov" <vladz@broadcom.com>
> Date: Tue, 14 Jun 2011 14:32:31 +0300
> 
> > We also send the new FW files to David Woodhouse. It's the first time we
> > submit to the linux-firmware git so I hope we don't mess the things up:
> > we DO NOT patch firmware/WHENCE and firmware/Makefile files in our
> > net-next patches and we patch the WHENCE file in the linux-firmware
> > patch. Dave, pls., confirm if it's a correct procedure.
> > 
> > If it is, pls., note that the bnx2x driver will compile but won't work
> > until u integrate the new FW into the kernel tree.
> 
> David Woodhouse, what do you think we should do here?
> 
> I'm inclined to integrate the firmware into net-next-2.6 since this
> is the only way to keep the driver working consistently.
> 
> Otherwise people won't be able to git bisect properly, and that sucks.

Dave, as long as /lib/firmware contains all existing firmwares there should be 
no problems, isn't it?

thanks,
vlad

