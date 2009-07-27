From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: RE: [PATCH NEXT 12/12] netxen: update version to 4.0.41
Date: Mon, 27 Jul 2009 12:26:58 -0700
Message-ID: <7608421F3572AB4292BB2532AE89D56581877E22A4@AVEXMB1.qlogic.org>
References: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
	<1248674867-18821-13-git-send-email-dhananjay@netxen.com>
	<20090727.103842.52201957.davem@davemloft.net>
 <20090727.105403.202219074.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:35292 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbZG0T1D convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 15:27:03 -0400
In-Reply-To: <20090727.105403.202219074.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, the idea for module params was to set global defaults
(configured in modprobe.conf) vs. per interface ethtool calls.
The ethtool support is anyway added by # 12 patch.

Is it not good to have both options available? 

I will sync up my tree and see if the merge is functionally
correct.

Thanks,
Dhananjay

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net] 
> Sent: Monday, July 27, 2009 10:54
> To: Dhananjay Phadke
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH NEXT 12/12] netxen: update version to 4.0.41
> 
> 
> Ok, in order to make this build I'm going to have to insert
> some parts of patch #6 which I rejected because that adds
> ring size defaults/max/etc. defines which get used by later
> patches.
> 
> No virus found in this incoming message.
> Checked by AVG - www.avg.com 
> Version: 8.5.392 / Virus Database: 270.13.25/2256 - Release 
> Date: 07/27/09 05:58:00
> 