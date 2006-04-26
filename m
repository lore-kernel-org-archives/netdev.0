From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] e1000: skb truesize fix
Date: Wed, 26 Apr 2006 00:31:28 -0700 (PDT)
Message-ID: <20060426.003128.87237239.davem@davemloft.net>
References: <20060426061229.25966.83974.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, jgarzik@pobox.com, netdev@vger.kernel.org,
	john.ronciak@intel.com, jesse.brandeburg@intel.com,
	Jeffrey.t.kirsher@intel.com, auke@foo-projects.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:32436
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751099AbWDZHba (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 03:31:30 -0400
To: auke-jan.h.kok@intel.com
In-Reply-To: <20060426061229.25966.83974.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Date: Tue, 25 Apr 2006 23:12:30 -0700

> This patch was already merged in Jeff Garzik's netdev upstream branch but
> needs to go into 12.6.16.y and 2.6.17rc* as it fixes a critical buffersize
> skb bug that is exposed by an earlier patch by Dave Miller and Herbert
> Xiu. I'm therefore resending it:
> 
> Please apply to 2.6.16.y and queue for 2.6.17-rc.
> 
> These changes are available through git. Jeff, please pull from:
> 
> git://lost.foo-projects.org/~ahkok/git/linux-2.6 skb_truesize
> 
> these patches are against
>  linux-2.6.git#master 4d5c34ec7b007cfb0771a36996b009f194acbb2f

ACK on the -stable submission.  Jeff can take care of 2.6.17-x
