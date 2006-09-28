From: Andreas Jellinghaus <aj@ciphirelabs.com>
Subject: Re: [ACRYPTO] New asynchronous crypto layer (acrypto) release.
Date: Thu, 28 Sep 2006 15:23:43 +0200
Message-ID: <451BCCDF.5000201__14002.1316278309$1159451344$gmane$org@ciphirelabs.com>
References: <20060928120826.GA18063@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:2765 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1751098AbWI1Nqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 09:46:35 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1GSwCE-0003kd-Jk
	for netdev@vger.kernel.org; Thu, 28 Sep 2006 15:45:02 +0200
Received: from ciphirelabs.net ([217.72.114.248])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2006 15:45:02 +0200
Received: from aj by ciphirelabs.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2006 15:45:02 +0200
To: netdev@vger.kernel.org
In-Reply-To: <20060928120826.GA18063@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> Hello.
> 
> I'm pleased to announce asynchronous crypto layer (acrypto) [1] release 
> for 2.6.18 kernel tree. Acrypto allows to handle crypto requests 
> asynchronously in hardware.
> 
> Combined patchset includes:
>  * acrypto core
>  * IPsec ESP4 port to acrypto
>  * dm-crypt port to acrypto

so I should be able to replace a plain 2.6.18 kernel with one
with this patchset and use dm-crypt'ed partitions (e.g. swap,
encrypted root filesystem) as usual without further changes?

Did anyone test this with success?

Regards, Andreas

