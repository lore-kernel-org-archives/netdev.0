From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 & TX offload
Date: Tue, 16 Oct 2007 19:25:17 +0200
Message-ID: <20071016172517.GA8120@electric-eye.fr.zoreil.com>
References: <4714D785.3000402@vlnb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Vladislav Bolkhovitin <vst@vlnb.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:42935 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759311AbXJPR2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 13:28:41 -0400
Content-Disposition: inline
In-Reply-To: <4714D785.3000402@vlnb.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(please remove l-k from the Cc:, this ought to be sent to netdev)

Vladislav Bolkhovitin <vst@vlnb.net> :
>
> I've recently bought Realtek RTL8169S-32 chip based Gigabit Ethernet card:
> 
> # lspci -vv
[...]
> I've noticed that all TX offload features (tx-checksumming, 
> scatter-gather and TSO) are disabled by default and should be manually 
> enabled by ethtool. I wonder, is there any particular reason for that? 

As far as I can tell, it is mostly a lack of pressure from the users and
my desire to avoid a change of behavior.

> Why they are not enabled by default as it was done for e1000 or tg3? Are 
> there any hidden drawbacks in enabling them?

None that I know of. I had not noticed a huge difference and people did
not comment a lot either...

> Those offload options are definitely work. They give in my setup (32-bit 
> 66MHz PCI, Xeon 1.7GHz CPU, open-iscsi) CPU offload from 75% to 45% and 
> data write throughput improvement from 55MB/s to 59MB/s.

...but your datapoint is welcome.

-- 
Ueimor
