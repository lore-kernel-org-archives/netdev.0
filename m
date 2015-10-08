From: Andy Gross <agross@codeaurora.org>
Subject: Re: [PATCH] Bluetooth: hci_smd: Qualcomm WCNSS HCI driver
Date: Thu, 8 Oct 2015 12:28:19 -0500
Message-ID: <20151008172819.GA32381@qualcomm.com>
References: <1443654180-29416-1-git-send-email-bjorn.andersson@sonymobile.com>
 <036E1E75-8E6A-4116-A648-A188A8458416@holtmann.org>
 <20151001203338.GW24668@usrtlx11787.corpusers.net>
 <31CC1992-41BB-484C-9784-3A54D0EF6FF3@holtmann.org>
 <20151008170744.GF24668@usrtlx11787.corpusers.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Fengwei Yin <fengwei.yin@linaro.org>,
	Srinivas Kandagatla <srinivas.kandagatla@linaro.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-bluetooth <linux-bluetooth@vger.kernel.org>,
	"linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Bjorn Andersson <bjorn.andersson@sonymobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:46770 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965137AbbJHR2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 13:28:23 -0400
Content-Disposition: inline
In-Reply-To: <20151008170744.GF24668@usrtlx11787.corpusers.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 08, 2015 at 10:07:44AM -0700, Bjorn Andersson wrote:
> On Sat 03 Oct 09:55 PDT 2015, Marcel Holtmann wrote:
> 
> > Hi Bjorn,
> > 
> [..]
> > >> Especially the kbuild test robot complained loudly.
> > >>
> > >
> > > Sorry, I forgot to mention in the patch that the patch depends on the
> > > qcom_smd_id patch - that's available in linux-next. I will take another
> > > look, but I think that was the cause of all the issues.
> > 
> > which means, I can only merge this driver when this other patch has
> > hit net-next tree. Unless I take the qcom_smd_id through
> > bluetooth-next tree which doesn't look like a good idea.
> > 
> 
> I was going to suggest that we just wait for -rc1, but the new additions
> to SMD adds a bunch of new items on the dependency list.
> 
> Perhaps once we agree we can get your Ack and have Andy pull it through
> the qcom-soc tree together with the SMD patches?

This is fine by me.

> > >>> obj-$(CONFIG_BT_INTEL)              += btintel.o
> > >>> obj-$(CONFIG_BT_ATH3K)              += ath3k.o
> > >>> diff --git a/drivers/bluetooth/hci_smd.c b/drivers/bluetooth/hci_smd.c
> > > [..]
> > >>> +#include <net/bluetooth/hci.h>
> > >>
> > >> The hci.h include is not needed. If you do, then you are doing
> > >> something fishy.
> > >>
> > >

<snip>

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project
