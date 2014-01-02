From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net-next v4 07/16] i40e: Rx checksum offload for VXLAN
Date: Thu, 2 Jan 2014 23:31:48 +0200
Message-ID: <CAJZOPZK_b=Ve1YXsHfZjyeOQiMxj_jAKscmgZT_AKCEK1+V1UA@mail.gmail.com>
References: <1388200940-9113-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1388200940-9113-8-git-send-email-jeffrey.t.kirsher@intel.com>
	<CAJZOPZ+XpHNcMdOKYpALvUXq5-yYuxcwAqG2AEe4DU=d=VGPtg@mail.gmail.com>
	<alpine.LFD.2.03.1401021252500.4979@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:41785 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbaABVbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 16:31:48 -0500
Received: by mail-pa0-f44.google.com with SMTP id fa1so14982490pad.31
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 13:31:48 -0800 (PST)
In-Reply-To: <alpine.LFD.2.03.1401021252500.4979@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 2, 2014 at 10:57 PM, Joseph Gasparakis
<joseph.gasparakis@intel.com> wrote:

>
> > The comment says that the driver has to compute the udp checksum
> > **if** the packet has an outer udp checksum,
> > but the driver call to issue checksumming is done unconditionally
>
>
> This code runs when the right bits are set in the rx hardware descriptor
> field (rx_ptype and rx_status), which implies the hardware has detected
> ipv4 tunneling and there is non zero UDP csum.


Got it -- thanks for explaining, also for the pointer on where
skb->encapsulation is set
